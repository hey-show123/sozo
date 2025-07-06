import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/services/achievement_service.dart';

// レベルアップ情報クラス
class LevelUpInfo {
  final bool hasLeveledUp;
  final int oldLevel;
  final int newLevel;
  final int totalXP;

  LevelUpInfo({
    required this.hasLeveledUp,
    required this.oldLevel,
    required this.newLevel,
    required this.totalXP,
  });

  factory LevelUpInfo.noLevelUp(int currentLevel, int totalXP) {
    return LevelUpInfo(
      hasLeveledUp: false,
      oldLevel: currentLevel,
      newLevel: currentLevel,
      totalXP: totalXP,
    );
  }
}

class ProgressService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // レッスン開始
  Future<void> startLesson(String lessonId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      await _supabase.from('user_lesson_progress').upsert({
        'user_id': userId,
        'lesson_id': lessonId,
        'status': 'in_progress',
        'last_attempt_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,lesson_id');
    } catch (e) {
      print('Error starting lesson: $e');
    }
  }
  
  // アクティビティ完了
  Future<(int, LevelUpInfo)> completeActivity({
    required String lessonId,
    required String activityType,
    required double score,
    required int timeSpent,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return (0, LevelUpInfo.noLevelUp(1, 0));
    
    try {
      // 現在のレベルとXPを取得
      final profileBefore = await _supabase
          .from('profiles')
          .select('total_xp, current_level')
          .eq('id', userId)
          .single();
      
      final oldLevel = (profileBefore['current_level'] as num?)?.toInt() ?? 1;
      final oldXP = (profileBefore['total_xp'] as num?)?.toInt() ?? 0;
      
      // 1. 進捗を更新
      final progress = await _supabase
          .from('user_lesson_progress')
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .single();
      
      final currentBestScore = (progress['best_score'] as num?)?.toDouble() ?? 0.0;
      final currentTimeSpent = (progress['total_time_spent'] as num?)?.toInt() ?? 0;
      final currentAttempts = (progress['attempts_count'] as num?)?.toInt() ?? 0;
      
      await _supabase.from('user_lesson_progress').update({
        'best_score': score > currentBestScore ? score : currentBestScore,
        'total_time_spent': currentTimeSpent + timeSpent,
        'attempts_count': currentAttempts + 1,
        'status': score >= 80 ? 'completed' : 'in_progress',
        'completed_at': score >= 80 ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('lesson_id', lessonId);
      
      // 2. XP計算
      int xpEarned = calculateXP(activityType, score);
      
      // 3. Supabaseの関数を使ってXPとストリークを更新
      await _supabase.rpc('add_user_xp', params: {
        'p_user_id': userId,
        'p_xp_amount': xpEarned,
      });
      
      await _supabase.rpc('update_user_streak', params: {
        'p_user_id': userId,
      });
      
      // 4. 更新後のレベルとXPを取得
      final profileAfter = await _supabase
          .from('profiles')
          .select('total_xp, current_level')
          .eq('id', userId)
          .single();
      
      final newLevel = (profileAfter['current_level'] as num?)?.toInt() ?? 1;
      final newXP = (profileAfter['total_xp'] as num?)?.toInt() ?? 0;
      
      // 5. レベルアップ情報を作成
      final levelUpInfo = oldLevel < newLevel
          ? LevelUpInfo(
              hasLeveledUp: true,
              oldLevel: oldLevel,
              newLevel: newLevel,
              totalXP: newXP,
            )
          : LevelUpInfo.noLevelUp(newLevel, newXP);
      
      // 6. 学習アクティビティを記録
      await _supabase.rpc('record_learning_activity', params: {
        'p_user_id': userId,
        'p_minutes': (timeSpent / 60).round(),
        'p_xp_earned': xpEarned,
        'p_lesson_id': lessonId,
      });
      
      return (xpEarned, levelUpInfo);
      
    } catch (e) {
      print('Error completing activity: $e');
      return (0, LevelUpInfo.noLevelUp(1, 0));
    }
  }
  
  // XP計算
  int calculateXP(String activityType, double score) {
    int baseXP = 100;
    
    // アクティビティタイプボーナス
    switch (activityType) {
      case 'key_phrase':
        baseXP = 80;
        break;
      case 'dialog':
        baseXP = 120;
        break;
      case 'ai_conversation':
        baseXP = 150;
        break;
      case 'pronunciation_test':
        baseXP = 100;
        break;
    }
    
    // スコアボーナス
    if (score >= 90) {
      baseXP += 50;
    } else if (score >= 80) {
      baseXP += 30;
    } else if (score >= 70) {
      baseXP += 10;
    }
    
    return baseXP;
  }
  
  // ユーザーXP更新
  Future<void> updateUserXP(int xpGained) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      final profile = await _supabase
          .from('profiles')
          .select('total_xp')
          .eq('id', userId)
          .single();
      
      final currentXP = (profile['total_xp'] as num?)?.toInt() ?? 0;
      final newXP = currentXP + xpGained;
      final newLevel = (newXP / 1000).floor() + 1;
      
      await _supabase.from('profiles').update({
        'total_xp': newXP,
        'current_level': newLevel,
      }).eq('id', userId);
      
    } catch (e) {
      print('Error updating XP: $e');
    }
  }
  
  // チュートリアル完了ボーナス
  Future<void> addTutorialBonus() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      // Supabaseの関数を使って50 XPのボーナスを追加
      await _supabase.rpc('add_user_xp', params: {
        'p_user_id': userId,
        'p_xp_amount': 50,
      });
      
      // チュートリアル完了をアクティビティとして記録
      await _supabase.rpc('record_learning_activity', params: {
        'p_user_id': userId,
        'p_minutes': 5, // チュートリアルの想定時間
        'p_xp_earned': 50,
        'p_lesson_id': 'tutorial',
      });
      
      print('Tutorial bonus added: 50 XP');
    } catch (e) {
      print('Error adding tutorial bonus: $e');
    }
  }
  
  // ストリーク更新
  Future<void> updateStreak() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    
    try {
      final profile = await _supabase
          .from('profiles')
          .select('last_study_date, streak_count, longest_streak')
          .eq('id', userId)
          .single();
      
      final today = DateTime.now().toLocal();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      final lastStudyDateStr = profile['last_study_date'] as String?;
      final currentStreak = (profile['streak_count'] as num?)?.toInt() ?? 0;
      final longestStreak = (profile['longest_streak'] as num?)?.toInt() ?? 0;
      
      int newStreak = currentStreak;
      
      if (lastStudyDateStr == null) {
        // 初回学習
        newStreak = 1;
      } else {
        final lastStudyDate = DateTime.parse(lastStudyDateStr);
        final daysDiff = today.difference(lastStudyDate).inDays;
        
        if (daysDiff == 0) {
          // 同じ日
          return;
        } else if (daysDiff == 1) {
          // 連続
          newStreak = currentStreak + 1;
        } else {
          // リセット
          newStreak = 1;
        }
      }
      
      await _supabase.from('profiles').update({
        'last_study_date': todayStr,
        'streak_count': newStreak,
        'longest_streak': newStreak > longestStreak ? newStreak : longestStreak,
      }).eq('id', userId);
      
    } catch (e) {
      print('Error updating streak: $e');
    }
  }
  
  // 実績チェック
  Future<List<Achievement>> checkAchievements() async {
    final achievementService = AchievementService();
    return await achievementService.checkAndUnlockAchievements();
  }

  // レベル計算関数
  static int calculateLevelFromXP(int totalXP) {
    return (totalXP / 1000).floor() + 1;
  }

  // 次のレベルまでに必要なXP
  static int xpToNextLevel(int totalXP) {
    final currentLevel = calculateLevelFromXP(totalXP);
    final nextLevelXP = currentLevel * 1000;
    return nextLevelXP - totalXP;
  }
}

// プロバイダー
final progressServiceProvider = Provider((ref) => ProgressService()); 