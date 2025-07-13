import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/leaderboard_provider.dart';
import 'package:sozo_app/presentation/widgets/level_progress_avatar.dart';
import 'package:sozo_app/core/theme/app_theme.dart';

class WeeklyLeaderboardScreen extends ConsumerStatefulWidget {
  const WeeklyLeaderboardScreen({super.key});

  @override
  ConsumerState<WeeklyLeaderboardScreen> createState() => _WeeklyLeaderboardScreenState();
}

class _WeeklyLeaderboardScreenState extends ConsumerState<WeeklyLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllRankings = true; // true: 全体, false: フレンド
  String? _selectedLeagueId; // 選択されたリーグ

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
    // 自動更新を有効化
    ref.watch(leaderboardAutoRefreshProvider);

    // 現在のユーザーのリーグ情報を取得
    final userRankInfo = ref.watch(userWeeklyRankProvider);
    
    // 初期表示時は現在のユーザーのリーグを選択
    if (_selectedLeagueId == null) {
      userRankInfo.whenData((info) {
        _selectedLeagueId = info.league;
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('週間ランキング'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // リーグ選択ボタン
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLeagueDisplayName(_selectedLeagueId),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            onSelected: (league) {
              setState(() {
                _selectedLeagueId = league;
              });
            },
            itemBuilder: (context) => League.values.map((league) {
              return PopupMenuItem<String>(
                value: league.id,
                child: Row(
                  children: [
                    Image.asset(
                      league.iconAsset,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(league.displayName),
                    if (_selectedLeagueId == league.id) ...[
                      const Spacer(),
                      Icon(
                        Icons.check,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _showAllRankings = index == 0;
            });
          },
          tabs: const [
            Tab(text: '全体'),
            Tab(text: 'フレンド'),
          ],
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weeklyLeaderboardProvider);
          ref.invalidate(friendsLeaderboardProvider);
          ref.invalidate(userWeeklyRankProvider);
          if (_selectedLeagueId != null) {
            ref.invalidate(leagueLeaderboardProvider(_selectedLeagueId!));
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllRankings(),
            _buildFriendsRankings(),
          ],
        ),
      ),
    );
  }

  String _getLeagueDisplayName(String? leagueId) {
    if (leagueId == null) return 'リーグ選択';
    final league = League.fromString(leagueId);
    return league.displayName;
  }

  Widget _buildAllRankings() {
    final userRankAsync = ref.watch(userWeeklyRankProvider);

    // 選択されたリーグのランキングを取得
    final leaderboardAsync = _selectedLeagueId != null
        ? ref.watch(leagueLeaderboardProvider(_selectedLeagueId!))
        : ref.watch(weeklyLeaderboardProvider);

    return Column(
      children: [
        // 自分の順位カード（自分のリーグの場合のみ表示）
        userRankAsync.when(
          data: (userRank) {
            if (_selectedLeagueId == null || _selectedLeagueId == userRank.league) {
              return _buildMyRankCard(userRank);
            } else {
              // 他のリーグを見ている場合はリーグ情報を表示
              return _buildLeagueInfoCard();
            }
          },
          loading: () => _buildMyRankCardLoading(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // ランキングリスト
        Expanded(
          child: leaderboardAsync.when(
            data: (entries) => _buildLeaderboardList(entries),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'ランキングの読み込みに失敗しました',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedLeagueId != null) {
                        ref.invalidate(leagueLeaderboardProvider(_selectedLeagueId!));
                      } else {
                      ref.invalidate(weeklyLeaderboardProvider);
                      }
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsRankings() {
    final friendsAsync = ref.watch(friendsLeaderboardProvider);

    return friendsAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'フレンドがいません',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'フレンドを追加して一緒に学習しましょう！',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: フレンド追加画面へ遷移
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('フレンドを追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildLeaderboardList(entries);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('フレンドランキングの読み込みに失敗しました'),
      ),
    );
  }

  Widget _buildMyRankCard(UserRankInfo userRank) {
    if (userRank.rank == 0) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'まだランキングに参加していません',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '学習を始めてランキングに参加しよう！',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getRankGradientColors(userRank.rank),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRankColor(userRank.rank).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ランクアイコン
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: userRank.rank <= 3
                  ? _getRankIcon(userRank.rank)
                  : Text(
                      '${userRank.rank}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // ランク情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'あなたの順位',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${userRank.rank}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '位 / ${userRank.totalUsers}人中',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 週間XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '週間XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                '${userRank.score}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCardLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLeagueInfoCard() {
    final league = League.fromString(_selectedLeagueId ?? 'bronze');
    final summaryAsync = ref.watch(allLeaguesSummaryProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(league.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.8),
            Color(int.parse(league.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(league.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                league.iconAsset,
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 12),
              Text(
                league.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          summaryAsync.when(
            data: (summary) {
              final leagueData = summary[_selectedLeagueId];
              if (leagueData != null) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLeagueStatItem(
                      label: '参加者',
                      value: '${leagueData['total_users']}人',
                    ),
                    _buildLeagueStatItem(
                      label: '最高XP',
                      value: '${leagueData['max_xp']}',
                    ),
                    _buildLeagueStatItem(
                      label: '平均XP',
                      value: '${(leagueData['avg_xp'] as num).toStringAsFixed(0)}',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueStatItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('まだランキングデータがありません'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardItem(entry, index);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isTopThree = entry.rank <= 3;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isTopThree ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _getRankColor(entry.rank).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 順位
            Container(
              width: 40,
              alignment: Alignment.center,
              child: isTopThree
                  ? _getRankIcon(entry.rank)
                  : Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // アバター
            LevelProgressAvatar(
              avatarUrl: entry.avatarUrl,
              currentLevel: entry.currentLevel,
              remainingXp: _calculateRemainingXp(entry.totalXp, entry.currentLevel),
              size: 48,
              progress: _calculateLevelProgress(entry.totalXp, entry.currentLevel),
              progressColor: entry.isCurrentUser ? AppTheme.primaryColor : Colors.amber,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.displayNameOrUsername,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: entry.isCurrentUser ? AppTheme.primaryColor : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (entry.isCurrentUser)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Lv.${entry.currentLevel}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.score} XP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTopThree ? _getRankColor(entry.rank) : Colors.grey[700],
              ),
            ),
            if (entry.movement != 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.movement > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: entry.movement > 0 ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${entry.movement.abs()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: entry.movement > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return const Icon(Icons.emoji_events, color: Colors.amber, size: 32);
      case 2:
        return const Icon(Icons.emoji_events, color: Colors.grey, size: 28);
      case 3:
        return const Icon(Icons.emoji_events, color: Colors.orange, size: 24);
      default:
        return Text(
          '$rank',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  List<Color> _getRankGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [Colors.amber.shade400, Colors.amber.shade600];
      case 2:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 3:
        return [Colors.orange.shade400, Colors.orange.shade600];
      default:
        if (rank <= 10) {
          return [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)];
        }
        return [Colors.blue.shade300, Colors.blue.shade500];
    }
  }

  double _calculateLevelProgress(int totalXp, int currentLevel) {
    final currentLevelXp = (currentLevel - 1) * 1000;
    final nextLevelXp = currentLevel * 1000;
    final progressXp = totalXp - currentLevelXp;
    final neededXp = nextLevelXp - currentLevelXp;
    
    if (neededXp <= 0) return 0.0;
    return (progressXp / neededXp).clamp(0.0, 1.0);
  }

  int _calculateRemainingXp(int totalXp, int currentLevel) {
    final nextLevelXp = currentLevel * 1000;
    return (nextLevelXp - totalXp).clamp(0, 999999);
  }
} 