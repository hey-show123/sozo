import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/animated_avatar.dart';
import '../../providers/auth_provider.dart';

class WeeklyLeaderboardScreen extends ConsumerStatefulWidget {
  const WeeklyLeaderboardScreen({super.key});

  @override
  ConsumerState<WeeklyLeaderboardScreen> createState() => _WeeklyLeaderboardScreenState();
}

class _WeeklyLeaderboardScreenState extends ConsumerState<WeeklyLeaderboardScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = ref.watch(authProvider).currentUser?.uid;
    final userRankInfo = ref.watch(userWeeklyRankProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('週間ランキング'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // ユーザーのリーグ情報
              userRankInfo.when(
                data: (info) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(info.leagueColor.substring(1), radix: 16) + 0xFF000000),
                        Color(int.parse(info.leagueColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(int.parse(info.leagueColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        info.leagueIcon,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${info.league.toUpperCase()}リーグ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '上位${info.percentile.toStringAsFixed(1)}%',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            if (info.nextLeague != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '次のリーグまで: ${info.xpToNextLeague} XP',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // タブバー
              TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                tabs: const [
                  Tab(text: '全体'),
                  Tab(text: 'フレンド'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 全体ランキング
          ref.watch(weeklyLeaderboardProvider).when(
            data: (entries) => _buildRankingList(entries, userId),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('エラーが発生しました: $error'),
            ),
          ),
          // フレンドランキング
          ref.watch(friendsWeeklyLeaderboardProvider).when(
            data: (entries) => _buildRankingList(entries, userId),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('エラーが発生しました: $error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(List<LeaderboardEntry> entries, String? currentUserId) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('まだランキングデータがありません'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weeklyLeaderboardProvider);
        ref.invalidate(friendsWeeklyLeaderboardProvider);
        ref.invalidate(userWeeklyRankProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final isCurrentUser = entry.userId == currentUserId;
          
          return _buildRankingCard(
            context, 
            entry, 
            isCurrentUser,
          );
        },
      ),
    );
  }

  Widget _buildRankingCard(
    BuildContext context, 
    LeaderboardEntry entry,
    bool isCurrentUser,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
          ? Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            )
          : null,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // プロフィール画面へ遷移など
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 順位
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getRankColor(entry.rank).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: entry.rank <= 3
                      ? _getRankIcon(entry.rank)
                      : Text(
                          '${entry.rank}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRankColor(entry.rank),
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                // アバター
                AnimatedAvatar(
                  imageUrl: entry.avatarUrl,
                  radius: 25,
                ),
                const SizedBox(width: 12),
                // ユーザー情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // リーグバッジ
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(int.parse(entry.leagueColor.substring(1), radix: 16) + 0xFF000000).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.leagueIcon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.league.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(int.parse(entry.leagueColor.substring(1), radix: 16) + 0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${entry.score} XP',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (entry.movement != 0) ...[
                            const SizedBox(width: 8),
                            Icon(
                              entry.movement > 0 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward,
                              size: 16,
                              color: entry.movement > 0 
                                ? Colors.green 
                                : Colors.red,
                            ),
                            Text(
                              '${entry.movement.abs()}',
                              style: TextStyle(
                                color: entry.movement > 0 
                                  ? Colors.green 
                                  : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 36));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 36));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 36));
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }
} 