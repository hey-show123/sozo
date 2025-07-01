import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 実績サービスのプロバイダー
final achievementServiceProvider = Provider((ref) => AchievementService());

// 実績モデル
class Achievement {
  final String id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final Map<String, dynamic> unlockCriteria;
  final String category;
  final DateTime? unlockedAt;
  final int currentProgress;
  final int targetValue;

  Achievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.unlockCriteria,
    required this.category,
    this.unlockedAt,
    this.currentProgress = 0,
    this.targetValue = 1,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // unlockCriteriaから進捗情報を抽出
    final criteria = json['unlock_criteria'] ?? {};
    int target = 1;
    
    // 条件タイプに応じてターゲット値を設定
    if (criteria['days'] != null) {
      target = criteria['days'] as int;
    } else if (criteria['amount'] != null) {
      target = criteria['amount'] as int;
    } else if (criteria['level'] != null) {
      target = criteria['level'] as int;
    } else if (criteria['count'] != null) {
      target = criteria['count'] as int;
    } else if (criteria['score'] != null) {
      target = criteria['score'] as int;
    }
    
    return Achievement(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'] ?? 'star',
      xpReward: json['xp_reward'] ?? 0,
      unlockCriteria: criteria,
      category: json['category'] ?? 'misc',
      unlockedAt: json['unlocked_at'] != null 
          ? DateTime.parse(json['unlocked_at']) 
          : null,
      currentProgress: json['current_progress'] ?? 0,
      targetValue: target,
    );
  }

  bool get isUnlocked => unlockedAt != null;
}

class AchievementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // すべての実績を取得
  Future<List<Achievement>> getAllAchievements() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // 実績マスターとユーザーの解除状況を結合して取得
      final response = await _supabase
          .from('achievements')
          .select('''
            *,
            user_achievements!left(unlocked_at)
          ''')
          .order('category', ascending: true)
          .order('xp_reward', ascending: true);

      return (response as List).map((json) {
        final userAchievement = json['user_achievements'] as List?;
        if (userAchievement != null && userAchievement.isNotEmpty) {
          json['unlocked_at'] = userAchievement[0]['unlocked_at'];
        }
        return Achievement.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // ユーザーの実績をチェックして新しく解除されたものを返す
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // ユーザーの統計情報を取得
      final profileResponse = await _supabase
          .from('profiles')
          .select('total_xp, current_level, streak_count')
          .eq('id', userId)
          .single();

      // 今日の学習状況を取得
      final today = DateTime.now().toLocal();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      final todayLearningResponse = await _supabase
          .from('learning_sessions')
          .select()
          .eq('user_id', userId)
          .eq('date', todayStr)
          .maybeSingle();

      // 発音セッションの統計を取得
      final pronunciationStatsResponse = await _supabase
          .rpc('get_pronunciation_stats', params: {
            'p_user_id': userId,
          });

      // 学習進捗の統計を取得
      final lessonStatsResponse = await _supabase
          .from('user_lesson_progress')
          .select('status')
          .eq('user_id', userId)
          .eq('status', 'completed');

      // AI会話の回数を取得
      final aiConversationResponse = await _supabase
          .from('ai_conversations')
          .select()
          .eq('user_id', userId);
      
      final aiConversationCount = (aiConversationResponse as List).length;

      // 未解除の実績を取得
      final unlockedAchievements = await _supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);
      
      final unlockedIds = (unlockedAchievements as List)
          .map((e) => e['achievement_id'] as String)
          .toSet();

      // すべての実績を取得
      final allAchievements = await _supabase
          .from('achievements')
          .select();

      final newlyUnlocked = <Achievement>[];

      // 各実績の条件をチェック
      for (final achievementJson in allAchievements as List) {
        final achievement = Achievement.fromJson(achievementJson);
        
        // すでに解除済みならスキップ
        if (unlockedIds.contains(achievement.id)) continue;

        final criteria = achievement.unlockCriteria;
        bool shouldUnlock = false;

        // 条件タイプに応じてチェック
        switch (criteria['type']) {
          case 'daily_streak':
            final requiredDays = criteria['days'] as int;
            final currentStreak = profileResponse['streak_count'] ?? 0;
            shouldUnlock = currentStreak >= requiredDays;
            break;

          case 'total_xp':
            final requiredXP = criteria['amount'] as int;
            final currentXP = profileResponse['total_xp'] ?? 0;
            shouldUnlock = currentXP >= requiredXP;
            break;

          case 'level_reached':
            final requiredLevel = criteria['level'] as int;
            final currentLevel = profileResponse['current_level'] ?? 1;
            shouldUnlock = currentLevel >= requiredLevel;
            break;

          case 'lesson_complete':
            final requiredCount = criteria['count'] as int;
            final completedCount = (lessonStatsResponse as List).length;
            shouldUnlock = completedCount >= requiredCount;
            break;

          case 'pronunciation_score':
            final requiredScore = criteria['score'] as int;
            final requiredCount = criteria['count'] as int;
            // 発音統計の実装は省略（RPCで実装が必要）
            break;

          case 'ai_conversations':
            final requiredCount = criteria['count'] as int;
            shouldUnlock = aiConversationCount >= requiredCount;
            break;

          case 'daily_lessons':
            final requiredCount = criteria['count'] as int;
            final todayLessons = todayLearningResponse?['lessons_completed'] ?? 0;
            shouldUnlock = todayLessons >= requiredCount;
            break;

          case 'study_time':
            final beforeHour = criteria['before_hour'] as int?;
            final afterHour = criteria['after_hour'] as int?;
            final currentHour = DateTime.now().hour;
            
            if (beforeHour != null) {
              shouldUnlock = currentHour < beforeHour;
            } else if (afterHour != null) {
              shouldUnlock = currentHour >= afterHour;
            }
            break;
        }

        // 条件を満たしていたら解除
        if (shouldUnlock) {
          await _unlockAchievement(achievement.id);
          newlyUnlocked.add(achievement);
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  // 実績を解除
  Future<void> _unlockAchievement(String achievementId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });

      // 実績のXPを付与
      final achievement = await _supabase
          .from('achievements')
          .select('xp_reward')
          .eq('id', achievementId)
          .single();

      if (achievement['xp_reward'] != null) {
        await _supabase.rpc('add_user_xp', params: {
          'p_user_id': userId,
          'p_xp_amount': achievement['xp_reward'],
        });
      }
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  // カテゴリ別に実績を取得
  Future<Map<String, List<Achievement>>> getAchievementsByCategory() async {
    final achievements = await getAllAchievements();
    final grouped = <String, List<Achievement>>{};

    for (final achievement in achievements) {
      grouped.putIfAbsent(achievement.category, () => []).add(achievement);
    }

    return grouped;
  }

  // 実績の進捗率を計算
  Future<double> getAchievementProgress() async {
    final achievements = await getAllAchievements();
    if (achievements.isEmpty) return 0.0;

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    return unlockedCount / achievements.length;
  }
} 