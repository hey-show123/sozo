import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/curriculum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_stats_provider.dart' as stats;
import '../../providers/profile_provider.dart';
import '../../widgets/weekly_learning_chart.dart';
import '../../widgets/streak_display.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/level_progress_avatar.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/achievement_service.dart';
import '../../widgets/achievement_notification.dart';
import '../../widgets/ranking_mini_card.dart';
import '../../widgets/daily_challenge_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // カリキュラムデータを読み込む
    Future.microtask(() {
      ref.read(curriculumProvider.notifier).loadCurriculums();
    });
    
    // 実績をチェック
    _checkAchievements();
  }
  
  Future<void> _checkAchievements() async {
    try {
      final achievementService = ref.read(achievementServiceProvider);
      final newAchievements = await achievementService.checkAndUnlockAchievements();
      
      if (newAchievements.isNotEmpty && mounted) {
        // 新しく解除された実績を順番に表示
        await Future.delayed(const Duration(seconds: 1)); // 画面が表示されるまで少し待つ
        if (mounted) {
          AchievementNotificationOverlay.showMultiple(context, newAchievements);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(profileNotifierProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(curriculumProvider.notifier).loadCurriculums();
          await ref.read(profileNotifierProvider.notifier).loadProfile();
        },
        child: CustomScrollView(
          slivers: [
            // カスタムAppBar
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
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
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: profileAsync.when(
                        data: (profile) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'こんにちは！',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      profile?.getDisplayName(user?.email) ?? 'ゲスト',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // アバターとレベル進捗
                                LevelProgressAvatar(
                                  avatarUrl: profile?.avatarUrl,
                                  progress: profile?.levelProgress ?? 0.0,
                                  currentLevel: profile?.currentLevel ?? 1,
                                  remainingXp: profile?.remainingXpToNextLevel ?? 0,
                                  size: 80,
                                  progressColor: Colors.amber,
                                  strokeWidth: 5,
                                ).animate()
                                  .fadeIn(duration: 600.ms, delay: 300.ms)
                                  .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack),
                              ],
                            ),
                            const Spacer(),
                            // ストリークとXP
                            Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.local_fire_department,
                                  value: profile?.streakCount.toString() ?? '0',
                                  label: '連続日数',
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 20),
                                _buildStatCard(
                                  icon: Icons.star,
                                  value: profile?.totalXp.toString() ?? '0',
                                  label: 'XP',
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        error: (_, __) => _buildDefaultHeader(user),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                    // 今日の学習時間
                    _buildSectionTitle('今日の学習時間', Icons.timer),
                    const SizedBox(height: 12),
                    _buildDailyGoalCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 推奨レッスン
                    _buildSectionTitle('次のレッスン', Icons.play_circle_outline),
                    const SizedBox(height: 12),
                    _buildRecommendedLessonCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // デイリーチャレンジ
                    _buildSectionTitle('デイリーチャレンジ', Icons.flag),
                    const SizedBox(height: 12),
                    const DailyChallengeCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 週間ランキング
                    _buildSectionTitle('週間ランキング', Icons.leaderboard),
                    const SizedBox(height: 12),
                    const RankingMiniCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDefaultHeader(User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'こんにちは！',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email?.split('@').first ?? 'ゲスト',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // デフォルトアバター
            LevelProgressAvatar(
              avatarUrl: null,
              progress: 0.0,
              currentLevel: 1,
              remainingXp: 100,
              size: 80,
              progressColor: Colors.amber,
              strokeWidth: 5,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 300.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack),
          ],
        ),
        const Spacer(),
        // デフォルトのストリークとXP
        Row(
          children: [
            _buildStatCard(
              icon: Icons.local_fire_department,
              value: '0',
              label: '連続日数',
              color: Colors.orange,
            ),
            const SizedBox(width: 20),
            _buildStatCard(
              icon: Icons.star,
              value: '0',
              label: 'XP',
              color: Colors.amber,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 3000.ms, delay: 1000.ms, color: color.withOpacity(0.4)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 500.ms, delay: 700.ms)
        .slideX(begin: -0.1, duration: 500.ms, curve: Curves.easeOut),
    );
  }
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDailyGoalCard() {
    return Consumer(
      builder: (context, ref, child) {
        final todayStats = ref.watch(stats.todayLearningStatsProvider);
        
        return todayStats.when(
          data: (statsData) {
            final totalMinutes = statsData.totalMinutes;
            final lessonsCompleted = statsData.lessonsCompleted;
            const dailyGoal = 30; // 1日の目標分数
            final progress = totalMinutes / dailyGoal;
            final remaining = dailyGoal - totalMinutes;
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.secondaryColor,
                AppTheme.primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '今日の学習時間',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${totalMinutes}分 / $dailyGoal分',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 12,
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .scaleX(begin: 0, duration: 800.ms, delay: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 20),
              Text(
                totalMinutes >= dailyGoal
                    ? '🎉 今日の目標を達成しました！'
                    : 'あと$remaining分で今日の目標達成！',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (lessonsCompleted > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '今日のレッスン: ${lessonsCompleted}個完了',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
          },
          loading: () => _buildDailyGoalCardDefault(),
          error: (_, __) => _buildDailyGoalCardDefault(),
        );
      },
    );
  }
  
  Widget _buildDailyGoalCardDefault() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryColor,
            AppTheme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日の学習時間',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '0分 / 30分',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          const Text(
            '今日の学習を始めましょう！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendedLessonCard(BuildContext context) {
    final supabase = ref.watch(supabaseProvider);
    return FutureBuilder(
      future: supabase
          .from('lessons')
          .select()
          .eq('is_active', true)
          .order('order_index', ascending: true)
          .limit(1)
          .single(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('レッスンの読み込みに失敗しました'),
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final lesson = snapshot.data as Map<String, dynamic>;
        
        return AnimatedCard(
          onTap: () {
            context.push('/lesson/${lesson['id']}');
          },
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(20),
          elevation: 8,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryColor.withOpacity(0.2),
                        AppTheme.primaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.cut,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms)
                  .rotate(duration: 600.ms, curve: Curves.easeOut),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title'] ?? 'レッスン',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
        );
      },
    );
  }
} 