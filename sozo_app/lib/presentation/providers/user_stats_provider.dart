import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/achievement_service.dart';

// ユーザー統計プロバイダー
final userStatsProvider = FutureProvider((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    print('UserStatsProvider: No user logged in');
    return UserStats.empty();
  }
  
  try {
    print('UserStatsProvider: Loading profile for user $userId');
    final profile = await supabase
        .from('profiles')
        .select('total_xp, current_level, streak_count, longest_streak')
        .eq('id', userId)
        .single();
    
    print('UserStatsProvider: Profile loaded - XP: ${profile['total_xp']}, Level: ${profile['current_level']}');
    
    // 今日の学習時間は一旦スキップ（テーブルが存在しない可能性）
    int todayMinutes = 0;
    try {
      final today = DateTime.now().toLocal();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      final todayData = await supabase
          .from('learning_sessions')
          .select('total_minutes')
          .eq('user_id', userId)
          .eq('session_date', todayStr)
          .maybeSingle();
      
      todayMinutes = todayData?['total_minutes'] ?? 0;
      print('UserStatsProvider: Today minutes loaded: $todayMinutes');
    } catch (e) {
      print('UserStatsProvider: Failed to load today minutes: $e');
      todayMinutes = 0; // デフォルト値を使用
    }
    
    return UserStats(
      totalXP: (profile['total_xp'] as num?)?.toInt() ?? 0,
      currentLevel: (profile['current_level'] as num?)?.toInt() ?? 1,
      streakCount: (profile['streak_count'] as num?)?.toInt() ?? 0,
      todayMinutes: todayMinutes,
      longestStreak: (profile['longest_streak'] as num?)?.toInt() ?? 0,
    );
  } catch (e) {
    print('UserStatsProvider: Error loading user stats: $e');
    return UserStats.empty();
  }
});

class UserStats {
  final int totalXP;
  final int currentLevel;
  final int streakCount;
  final int todayMinutes;
  final int longestStreak;
  
  UserStats({
    required this.totalXP,
    required this.currentLevel,
    required this.streakCount,
    required this.todayMinutes,
    required this.longestStreak,
  });
  
  factory UserStats.empty() => UserStats(
    totalXP: 0,
    currentLevel: 1,
    streakCount: 0,
    todayMinutes: 0,
    longestStreak: 0,
  );
  
  // エイリアスプロパティ
  int get level => currentLevel;
  int get currentStreak => streakCount;
}

// ユーザー実績プロバイダー
final userAchievementsProvider = FutureProvider((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    print('UserAchievementsProvider: No user logged in');
    return <UserAchievement>[];
  }
  
  print('UserAchievementsProvider: Loading achievements for user $userId');
  
  try {
    final response = await supabase
        .from('user_achievements')
        .select('*, achievements!inner(*)')
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);
    
    print('UserAchievementsProvider: Achievements loaded successfully');
    return (response as List).map((data) {
      final achievement = data['achievements'];
      return UserAchievement(
        id: data['id'] as String,
        userId: data['user_id'] as String,
        achievementId: data['achievement_id'] as String,
        unlockedAt: DateTime.parse(data['unlocked_at'] as String),
        achievement: Achievement(
          id: achievement['id'] as String,
          code: achievement['code'] as String? ?? '',
          title: achievement['title'] as String? ?? 'Unknown Achievement',
          description: achievement['description'] as String? ?? '',
          icon: achievement['icon'] as String? ?? 'star',
          xpReward: (achievement['xp_reward'] as num?)?.toInt() ?? 0,
          unlockCriteria: achievement['unlock_criteria'] as Map<String, dynamic>? ?? {},
          category: achievement['category'] as String? ?? 'misc',
          unlockedAt: DateTime.parse(data['unlocked_at'] as String),
        ),
      );
    }).toList();
  } catch (e) {
    print('UserAchievementsProvider: Failed to load achievements: $e');
    return <UserAchievement>[];
  }
});

class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final Achievement achievement;
  
  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    required this.achievement,
  });
}



// 今日の学習データプロバイダー
final todayLearningStatsProvider = FutureProvider((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    print('TodayLearningStatsProvider: No user logged in');
    return TodayLearningStats.empty();
  }
  
  print('TodayLearningStatsProvider: Loading today stats for user $userId');
  
  // テーブルが存在しない可能性があるため、デフォルト値を返す
  try {
    // 今日の学習サマリービューから取得を試行
    final response = await supabase
        .from('today_learning_summary')
        .select()
        .eq('user_id', userId)
        .single();
    
    print('TodayLearningStatsProvider: Data loaded from summary view');
    return TodayLearningStats(
      totalMinutes: (response['total_minutes'] as num?)?.toInt() ?? 0,
      xpEarned: (response['xp_earned'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (response['lessons_completed_count'] as num?)?.toInt() ?? 0,
      activitiesCount: (response['activities_completed'] as num?)?.toInt() ?? 0,
    );
  } catch (e) {
    print('TodayLearningStatsProvider: Summary view failed: $e');
    
    // ビューが存在しない場合は直接計算を試行
    try {
      final today = DateTime.now().toLocal();
      final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      
      final result = await supabase
          .from('learning_sessions')
          .select()
          .eq('user_id', userId)
          .eq('session_date', todayStr)
          .single();
      
      print('TodayLearningStatsProvider: Data loaded from sessions table');
      return TodayLearningStats(
        totalMinutes: (result['total_minutes'] as num?)?.toInt() ?? 0,
        xpEarned: (result['xp_earned'] as num?)?.toInt() ?? 0,
        lessonsCompleted: (result['lessons_completed'] as List?)?.length ?? 0,
        activitiesCount: (result['activities_completed'] as num?)?.toInt() ?? 0,
      );
    } catch (e2) {
      print('TodayLearningStatsProvider: Sessions table also failed: $e2');
      // テーブルが存在しない場合は空のデータを返す
      return TodayLearningStats.empty();
    }
  }
});

class TodayLearningStats {
  final int totalMinutes;
  final int xpEarned;
  final int lessonsCompleted;
  final int activitiesCount;
  
  TodayLearningStats({
    required this.totalMinutes,
    required this.xpEarned,
    required this.lessonsCompleted,
    required this.activitiesCount,
  });
  
  factory TodayLearningStats.empty() => TodayLearningStats(
    totalMinutes: 0,
    xpEarned: 0,
    lessonsCompleted: 0,
    activitiesCount: 0,
  );
}

// 週間学習データプロバイダー
final weeklyLearningStatsProvider = FutureProvider<List<DailyLearningStats>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) {
    print('WeeklyLearningStatsProvider: No user logged in');
    return [];
  }
  
  print('WeeklyLearningStatsProvider: Loading weekly stats for user $userId');
  
  try {
    // 過去7日間のデータを取得
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    
    final response = await supabase
        .from('learning_sessions')
        .select('session_date, total_minutes, lessons_completed, xp_earned')
        .eq('user_id', userId)
        .gte('session_date', startDate.toIso8601String().split('T')[0])
        .lte('session_date', endDate.toIso8601String().split('T')[0])
        .order('session_date', ascending: true);
    
    print('WeeklyLearningStatsProvider: Weekly data loaded successfully');
    return (response as List).map((data) {
      // lessons_completedは配列なので、その長さを計算
      final lessonsCompleted = data['lessons_completed'] as List?;
      return DailyLearningStats(
        date: DateTime.parse(data['session_date'] as String),
        totalMinutes: (data['total_minutes'] as num?)?.toInt() ?? 0,
        lessonsCompleted: lessonsCompleted?.length ?? 0,
        xpEarned: (data['xp_earned'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  } catch (e) {
    print('WeeklyLearningStatsProvider: Failed to load weekly stats: $e');
    // テーブルが存在しない場合は空のリストを返す
    return [];
  }
});

class DailyLearningStats {
  final DateTime date;
  final int totalMinutes;
  final int lessonsCompleted;
  final int xpEarned;
  
  DailyLearningStats({
    required this.date,
    required this.totalMinutes,
    required this.lessonsCompleted,
    required this.xpEarned,
  });
}

// 全実績プロバイダー（解除済み・未解除両方を含む）
final allAchievementsProvider = FutureProvider((ref) async {
  final service = ref.read(achievementServiceProvider);
  return await service.getAllAchievements();
}); 