import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_stats_provider.dart';
import '../../widgets/weekly_learning_chart.dart';
import '../../widgets/streak_display.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // カスタムAppBar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: theme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '学習進捗',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // コンテンツ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 総合統計
                  _buildSectionTitle('総合統計', Icons.assessment),
                  const SizedBox(height: 16),
                  _buildOverallStats(ref),
                  
                  const SizedBox(height: 32),
                  
                  // 習慣学習時間
                  _buildSectionTitle('習慣学習時間', Icons.calendar_today),
                  const SizedBox(height: 16),
                  const WeeklyLearningChart(),
                  
                  const SizedBox(height: 32),
                  
                  // 連続学習日数
                  _buildSectionTitle('連続学習日数', Icons.local_fire_department),
                  const SizedBox(height: 16),
                  const StreakDisplay(),
                  
                  const SizedBox(height: 32),
                  
                  // スキル別進捗
                  _buildSectionTitle('スキル別進捗', Icons.radar),
                  const SizedBox(height: 16),
                  _buildSkillProgress(ref),
                  
                  const SizedBox(height: 32),
                  
                  // 最近の実績
                  _buildSectionTitle('獲得した実績', Icons.emoji_events),
                  const SizedBox(height: 16),
                  _buildAchievementsList(ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOverallStats(WidgetRef ref) {
    final overallStatsAsync = ref.watch(overallStatsProvider);
    
    return overallStatsAsync.when(
      data: (stats) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3, // オーバーフロー対策：アスペクト比を調整
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildStatCard(
              icon: Icons.schedule,
              title: '総学習時間',
              value: '${stats.totalHours.toStringAsFixed(1)}時間',
              subtitle: '今月 +${(stats.totalHours * 0.3).toStringAsFixed(1)}時間',
              color: Colors.blue,
            ),
            _buildStatCard(
              icon: Icons.school,
              title: '完了レッスン',
              value: '${stats.completedLessons}',
              subtitle: '残り ${27 - stats.completedLessons}レッスン',
              color: Colors.green,
            ),
            _buildStatCard(
              icon: Icons.check_circle,
              title: '習慣達成率',
              value: '${(stats.weeklyGoalAchievement * 100).toInt()}%',
              subtitle: '今週の目標達成',
              color: Colors.purple,
            ),
            _buildStatCard(
              icon: Icons.star,
              title: '獲得XP',
              value: '${NumberFormat('#,###').format(stats.totalXP)}',
              subtitle: 'Lv${stats.currentLevel + 1}まで ${stats.xpToNextLevel}XP',
              color: Colors.amber,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('エラー: $error'),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // パディングを削減
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24), // アイコンサイズを削減
          const SizedBox(height: 4),
          Flexible( // Flexibleでラップ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox( // テキストを収まるようにフィット
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20, // フォントサイズを削減
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSkillProgress(WidgetRef ref) {
    final skillProgressAsync = ref.watch(skillProgressProvider);
    
    return skillProgressAsync.when(
      data: (skills) {
        final skillColors = {
          '発音': Colors.purple,
          '語彙': Colors.orange,
          '文法': Colors.green,
          '会話': Colors.blue,
        };
        
        return Column(
          children: skills.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: skillColors[entry.key] ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      skillColors[entry.key] ?? Colors.grey,
                    ),
                    minHeight: 8,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('エラー: $error'),
      ),
    );
  }
  
  Widget _buildAchievementsList(WidgetRef ref) {
    final achievementsAsync = ref.watch(unlockedAchievementsProvider);
    
    return achievementsAsync.when(
      data: (achievements) {
        if (achievements.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'まだ実績を獲得していません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final iconMap = {
          'milestone_first_lesson': Icons.school,
          'milestone_10_lessons': Icons.school,
          'milestone_50_lessons': Icons.school,
          'milestone_100_lessons': Icons.school,
          'streak_3_days': Icons.local_fire_department,
          'streak_7_days': Icons.local_fire_department,
          'streak_30_days': Icons.local_fire_department,
          'streak_100_days': Icons.local_fire_department,
          'skill_pronunciation_90': Icons.mic,
          'skill_pronunciation_perfect': Icons.mic,
          'skill_conversation_10': Icons.chat,
          'skill_conversation_50': Icons.chat,
          'challenge_speed_learner': Icons.speed,
          'challenge_night_owl': Icons.bedtime,
          'challenge_early_bird': Icons.wb_sunny,
          'challenge_weekend_warrior': Icons.weekend,
          'challenge_perfectionist': Icons.star,
          'challenge_vocabulary_master': Icons.book,
        };
        
        final colorMap = {
          'milestone': Colors.blue,
          'streak': Colors.orange,
          'skill': Colors.purple,
          'challenge': Colors.green,
        };
        
        return Column(
          children: achievements.map((achievement) {
            final iconName = achievement.icon;
            final icon = iconMap[iconName] ?? Icons.emoji_events;
            final color = colorMap[achievement.category] ?? Colors.grey;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy年MM月dd日').format(achievement.unlockedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('エラー: $error'),
      ),
    );
  }
} 