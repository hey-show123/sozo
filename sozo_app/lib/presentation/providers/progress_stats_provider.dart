import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:sozo_app/presentation/providers/user_stats_provider.dart';

// 週間学習データ
final weeklyLearningStatsProvider = FutureProvider<List<DailyStats>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  // 過去7日間のデータを取得
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 6));
  
  final response = await supabase
      .from('learning_sessions')
      .select()
      .eq('user_id', user.id)
      .gte('session_date', weekAgo.toIso8601String().split('T')[0])
      .order('session_date', ascending: true);
  
  final sessions = response as List;
  
  // 日別のマップを作成
  final Map<String, DailyStats> dailyMap = {};
  
  // 過去7日間の全ての日付を初期化
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = date.toIso8601String().split('T')[0];
    dailyMap[dateStr] = DailyStats(
      date: date,
      totalMinutes: 0,
      lessonsCompleted: 0,
      xpEarned: 0,
    );
  }
  
  // セッションデータを集計
  for (final session in sessions) {
    final dateStr = session['session_date'] as String;
    if (dailyMap.containsKey(dateStr)) {
      dailyMap[dateStr] = DailyStats(
        date: dailyMap[dateStr]!.date,
        totalMinutes: dailyMap[dateStr]!.totalMinutes + ((session['total_minutes'] ?? 0) as num).toInt(),
        lessonsCompleted: dailyMap[dateStr]!.lessonsCompleted + ((session['activities_completed'] ?? 0) as num).toInt(),
        xpEarned: dailyMap[dateStr]!.xpEarned + ((session['xp_earned'] ?? 0) as num).toInt(),
      );
    }
  }
  
  return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
});

// スキル別進捗データ
final skillProgressProvider = FutureProvider<Map<String, double>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return {};
  
  // 発音セッションのスコアを取得
  final pronunciationResponse = await supabase
      .from('pronunciation_sessions')
      .select('overall_score')
      .eq('user_id', user.id)
      .not('overall_score', 'is', null);
  
  final pronunciationScores = (pronunciationResponse as List)
      .map((s) => s['overall_score'] as num)
      .toList();
  
  double pronunciationAvg = 0;
  if (pronunciationScores.isNotEmpty) {
    pronunciationAvg = pronunciationScores.reduce((a, b) => a + b) / pronunciationScores.length / 100;
  }
  
  // レッスン進捗から他のスキルを推定
  final lessonProgress = await supabase
      .from('user_lesson_progress')
      .select('lesson_id, mastery_score')
      .eq('user_id', user.id);
  
  final progressList = lessonProgress as List;
  double vocabularyScore = 0.6; // デフォルト値
  double grammarScore = 0.8;
  double conversationScore = 0.5;
  
  // レッスンの完了状況から推定
  if (progressList.isNotEmpty) {
    final avgMastery = progressList
        .where((p) => p['mastery_score'] != null)
        .map((p) => p['mastery_score'] as num)
        .fold<double>(0, (sum, score) => sum + score) / progressList.length;
    
    vocabularyScore = (avgMastery * 0.8).clamp(0, 1);
    grammarScore = (avgMastery * 0.9).clamp(0, 1);
    conversationScore = (avgMastery * 0.7).clamp(0, 1);
  }
  
  return {
    '発音': pronunciationAvg,
    '語彙': vocabularyScore,
    '文法': grammarScore,
    '会話': conversationScore,
  };
});

// 獲得済み実績
final unlockedAchievementsProvider = FutureProvider<List<UnlockedAchievement>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  final response = await supabase
      .from('user_achievements')
      .select('''
        unlocked_at,
        achievements (
          id,
          title,
          description,
          icon,
          category
        )
      ''')
      .eq('user_id', user.id)
      .order('unlocked_at', ascending: false)
      .limit(10);
  
  return (response as List).map((data) {
    final achievement = data['achievements'];
    return UnlockedAchievement(
      id: achievement['id'],
      title: achievement['title'],
      description: achievement['description'],
      icon: achievement['icon'],
      category: achievement['category'],
      unlockedAt: DateTime.parse(data['unlocked_at']),
    );
  }).toList();
});

// 総合統計
final overallStatsProvider = FutureProvider<OverallStats>((ref) async {
  final userStats = await ref.watch(userStatsProvider.future);
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) {
    return OverallStats(
      totalHours: 0,
      completedLessons: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalXP: 0,
      currentLevel: 1,
      xpToNextLevel: 500,
      weeklyGoalAchievement: 0,
    );
  }
  
  // 総学習時間を計算
  final sessionsResponse = await supabase
      .from('learning_sessions')
      .select('total_minutes')
      .eq('user_id', user.id);
  
  final totalMinutes = (sessionsResponse as List)
      .map((s) => s['total_minutes'] ?? 0)
      .fold<int>(0, (sum, minutes) => sum + (minutes as num).toInt());
  
  // 完了レッスン数
  final completedResponse = await supabase
      .from('user_lesson_progress')
      .select('id')
      .eq('user_id', user.id)
      .eq('status', 'completed');
  
  final completedLessons = (completedResponse as List).length;
  
  // 週間目標達成率を計算
  double weeklyGoalAchievement = 0;
  try {
    // ユーザーの目標設定を取得
    final settingsResponse = await supabase
        .from('user_settings')
        .select('daily_goal_minutes')
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (settingsResponse != null) {
      final dailyGoalMinutes = (settingsResponse['daily_goal_minutes'] ?? 30) as int;
      
      // 今週の学習時間を取得
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      final weekResponse = await supabase
          .from('learning_sessions')
          .select('total_minutes')
          .eq('user_id', user.id)
          .gte('session_date', weekStart.toIso8601String().split('T')[0]);
      
      final weeklyMinutes = (weekResponse as List)
          .map((s) => s['total_minutes'] ?? 0)
          .fold<int>(0, (sum, minutes) => sum + (minutes as num).toInt());
      
      // 今週の目標時間（今日までの日数 × 日次目標）
      final daysThisWeek = now.weekday;
      final weeklyGoalMinutes = daysThisWeek * dailyGoalMinutes;
      
      weeklyGoalAchievement = weeklyGoalMinutes > 0 
          ? (weeklyMinutes / weeklyGoalMinutes).clamp(0.0, 1.0)
          : 0;
    }
  } catch (e) {
    print('Error calculating weekly goal achievement: $e');
  }
  
  // 次のレベルまでのXP計算
  final nextLevelXP = _calculateXPForLevel(userStats.level + 1);
  final currentLevelXP = _calculateXPForLevel(userStats.level);
  final xpToNextLevel = nextLevelXP - userStats.totalXP;
  
  return OverallStats(
    totalHours: totalMinutes / 60.0,
    completedLessons: completedLessons,
    currentStreak: userStats.currentStreak,
    longestStreak: userStats.longestStreak,
    totalXP: userStats.totalXP,
    currentLevel: userStats.level,
    xpToNextLevel: xpToNextLevel,
    weeklyGoalAchievement: weeklyGoalAchievement,
  );
});

int _calculateXPForLevel(int level) {
  // レベル毎に必要XPが増加する式
  return level * level * 100 + (level - 1) * 400;
}

// データモデル
class DailyStats {
  final DateTime date;
  final int totalMinutes;
  final int lessonsCompleted;
  final int xpEarned;
  
  DailyStats({
    required this.date,
    required this.totalMinutes,
    required this.lessonsCompleted,
    required this.xpEarned,
  });
}

class UnlockedAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final DateTime unlockedAt;
  
  UnlockedAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.unlockedAt,
  });
}

class OverallStats {
  final double totalHours;
  final int completedLessons;
  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final double weeklyGoalAchievement;
  
  OverallStats({
    required this.totalHours,
    required this.completedLessons,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXP,
    required this.currentLevel,
    required this.xpToNextLevel,
    required this.weeklyGoalAchievement,
  });
} 