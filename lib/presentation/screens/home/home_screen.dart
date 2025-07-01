import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/curriculum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_stats_provider.dart' as stats;
import '../../widgets/weekly_learning_chart.dart';
import '../../widgets/streak_display.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userStats = ref.watch(stats.userStatsProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(curriculumProvider.notifier).loadCurriculums();
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
                      child: Column(
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
                              // アバターとレベル
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 44,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      userStats.when(
                        data: (stats) => 'Lv.${stats.currentLevel}',
                        loading: () => 'Lv.1',
                        error: (_, __) => 'Lv.1',
                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          // ストリークとXP
                          userStats.when(
                            data: (stats) => Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.local_fire_department,
                                  value: stats.streakCount.toString(),
                                  label: '連続日数',
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 20),
                                _buildStatCard(
                                  icon: Icons.star,
                                  value: 'SOZO',
                                  label: '${stats.totalXP} XP',
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => Row(
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
                                  value: 'SOZO',
                                  label: '0 XP',
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'SOZO',
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
                    // 今日の目標
                    _buildSectionTitle('今日の目標', Icons.flag),
                    const SizedBox(height: 12),
                    _buildDailyGoalCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 週間学習グラフ
                    _buildSectionTitle('週間学習状況', Icons.show_chart),
                    const SizedBox(height: 12),
                    const WeeklyLearningChart(),
                    
                    const SizedBox(height: 24),
                    
                    // ストリーク表示
                    _buildSectionTitle('連続学習日数', Icons.local_fire_department),
                    const SizedBox(height: 12),
                    const StreakDisplay(),
                    
                    const SizedBox(height: 24),
                    
                    // 推奨レッスン
                    _buildSectionTitle('次のレッスン', Icons.play_circle_outline),
                    const SizedBox(height: 12),
                    _buildRecommendedLessonCard(context),
                    
                    const SizedBox(height: 24),
                    
                    // クイックアクション
                    _buildSectionTitle('クイックスタート', Icons.flash_on),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    
                    const SizedBox(height: 24),
                    
                    // 最近の実績
                    _buildSectionTitle('最近の実績', Icons.emoji_events),
                    const SizedBox(height: 12),
                    _buildRecentAchievements(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
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
      ),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
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
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 10,
              ),
              const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
        
        return InkWell(
          onTap: () {
            context.push('/lesson/${lesson['id']}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cut,
                    color: Colors.blue[700],
                    size: 30,
                  ),
                ),
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
          ),
        );
      },
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.chat_bubble,
            label: 'AI会話',
            color: Colors.purple,
            onTap: () => context.go('/chat'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.mic,
            label: '発音練習',
            color: Colors.orange,
            onTap: () => context.go('/test/pronunciation'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.quiz,
            label: '単語クイズ',
            color: Colors.green,
            onTap: () {
              // TODO: 単語クイズ画面へ
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentAchievements() {
    final achievements = [
      {'icon': Icons.local_fire_department, 'title': '3日連続学習', 'color': Colors.orange},
      {'icon': Icons.mic, 'title': '発音スコア90点達成', 'color': Colors.purple},
      {'icon': Icons.chat, 'title': '初めてのAI会話', 'color': Colors.blue},
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: achievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (achievement['color'] as Color).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  achievement['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: achievement['color'] as Color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
} 