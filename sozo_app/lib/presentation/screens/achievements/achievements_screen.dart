import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/achievement_service.dart';
import '../../providers/user_stats_provider.dart';
import '../../widgets/achievement_notification.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('実績'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          isScrollable: true,
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedCategory = 'all';
                  break;
                case 1:
                  _selectedCategory = 'milestone';
                  break;
                case 2:
                  _selectedCategory = 'streak';
                  break;
                case 3:
                  _selectedCategory = 'skill';
                  break;
                case 4:
                  _selectedCategory = 'challenge';
                  break;
              }
            });
          },
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: 'マイルストーン'),
            Tab(text: 'ストリーク'),
            Tab(text: 'スキル'),
            Tab(text: 'チャレンジ'),
          ],
        ),
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          final filteredAchievements = _selectedCategory == 'all'
              ? achievements
              : achievements.where((a) => a.category == _selectedCategory).toList();
          
          if (filteredAchievements.isEmpty) {
            return _buildEmptyState();
          }
          
          // カテゴリーごとにグループ化
          final groupedAchievements = <String, List<Achievement>>{};
          for (final achievement in filteredAchievements) {
            final category = achievement.category;
            groupedAchievements[category] ??= [];
            groupedAchievements[category]!.add(achievement);
          }
          
          return TabBarView(
            controller: _tabController,
            children: List.generate(5, (index) {
              return CustomScrollView(
                slivers: [
                  // 統計ヘッダー
                  SliverToBoxAdapter(
                    child: _buildStatisticsHeader(achievements),
                  ),
                  
                  // 実績リスト
                  if (_selectedCategory == 'all') ...[
                    // すべてのカテゴリーを表示
                    ...groupedAchievements.entries.map((entry) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            _getCategoryTitle(entry.key),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final achievement = entry.value[index];
                              return _buildAchievementCard(achievement);
                            },
                            childCount: entry.value.length,
                          ),
                        ),
                      ),
                    ]).expand((x) => x),
                  ] else ...[
                    // 単一カテゴリーを表示
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final achievement = filteredAchievements[index];
                            return _buildAchievementCard(achievement);
                          },
                          childCount: filteredAchievements.length,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(List<Achievement> achievements) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '実績解除率',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '解除済み: $unlockedCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                '総数: $totalCount',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.currentProgress / achievement.targetValue;
    
    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? _getCategoryColor(achievement.category)
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getCategoryColor(achievement.category).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // メインコンテンツ
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // アイコン
                  Icon(
                    _getCategoryIcon(achievement.category),
                    size: 48,
                    color: isUnlocked
                        ? _getCategoryColor(achievement.category)
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  
                  // タイトル（隠し実績の場合は未解除時に???表示）
                  Text(
                    achievement.isHidden && !isUnlocked 
                        ? '???' 
                        : achievement.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black87 : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // プログレスバー（隠し実績の場合は非表示）
                  if (!isUnlocked && !achievement.isHidden) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCategoryColor(achievement.category).withOpacity(0.7),
                            ),
                            minHeight: 6,
                          ),
                        ),
                        // 進捗が100%の場合は特別な表示
                        if (progress >= 1.0)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    _getCategoryColor(achievement.category),
                                    _getCategoryColor(achievement.category).withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress >= 1.0 
                          ? '達成！タップして解除'
                          : '${achievement.currentProgress} / ${achievement.targetValue}',
                      style: TextStyle(
                        fontSize: 12,
                        color: progress >= 1.0 
                            ? _getCategoryColor(achievement.category)
                            : Colors.grey[600],
                        fontWeight: progress >= 1.0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                  
                  // 隠し実績の場合のヒント
                  if (achievement.isHidden && !isUnlocked) ...[
                    Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '隠し実績',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  
                  // XP報酬
                  if (isUnlocked) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // ロックオーバーレイ（隠し実績の場合は異なる表示）
            if (!isUnlocked && !achievement.isHidden && progress < 1.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            
            // 隠し実績のロックオーバーレイ
            if (!isUnlocked && achievement.isHidden)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.visibility_off,
                      size: 32,
                      color: Colors.purple[300],
                    ),
                  ),
                ),
              ),
            
            // 解除日時または達成可能マーク
            if (isUnlocked && achievement.unlockedAt != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(achievement.category),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              )
            else if (!isUnlocked && progress >= 1.0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.celebration,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            
            // 特別な実績の場合のキラキラエフェクト
            if (achievement.category == 'special' && isUnlocked)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.pink.withOpacity(0.1),
                          Colors.transparent,
                          Colors.purple.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    // 進捗が100%の場合は解除処理を実行
    if (!achievement.isUnlocked && achievement.currentProgress >= achievement.targetValue && !achievement.isHidden) {
      _unlockAchievementManually(achievement);
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ハンドル
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // アイコン
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getCategoryColor(achievement.category).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(achievement.category),
                size: 64,
                color: _getCategoryColor(achievement.category),
              ),
            ),
            const SizedBox(height: 16),
            
            // タイトル
            Text(
              achievement.isHidden && !achievement.isUnlocked 
                  ? '???'
                  : achievement.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // 説明
            Text(
              achievement.isHidden && !achievement.isUnlocked
                  ? 'この実績の条件は秘密です。\n様々なことに挑戦してみましょう！'
                  : achievement.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 進捗状況
            if (!achievement.isUnlocked && !achievement.isHidden) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('進捗'),
                        Text(
                          '${achievement.currentProgress} / ${achievement.targetValue}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (achievement.currentProgress / achievement.targetValue).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(achievement.category),
                      ),
                    ),
                    if (achievement.currentProgress >= achievement.targetValue) ...[
                      const SizedBox(height: 8),
                      Text(
                        '達成済み！次回の同期で解除されます',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (achievement.isUnlocked) ...[
              // 解除情報
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          '達成済み',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (achievement.unlockedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '解除日: ${_formatDate(achievement.unlockedAt!)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            // XP報酬
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'XP報酬: ${achievement.xpReward}',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'まだ実績がありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '学習を続けて実績を解除しましょう！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'milestone':
        return 'マイルストーン';
      case 'streak':
        return 'ストリーク';
      case 'skill':
        return 'スキル';
      case 'challenge':
        return 'チャレンジ';
      case 'special':
        return '特別実績';
      default:
        return 'その他';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'milestone':
        return Icons.flag;
      case 'streak':
        return Icons.local_fire_department;
      case 'skill':
        return Icons.star;
      case 'challenge':
        return Icons.flash_on;
      case 'special':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'milestone':
        return Colors.purple;
      case 'streak':
        return Colors.orange;
      case 'skill':
        return Colors.blue;
      case 'challenge':
        return Colors.green;
      case 'special':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _unlockAchievementManually(Achievement achievement) async {
    try {
      final service = ref.read(achievementServiceProvider);
      final achievements = await service.checkAndUnlockAchievements();
      
      // 該当の実績が解除されたか確認
      final unlockedAchievement = achievements.firstWhere(
        (a) => a.id == achievement.id,
        orElse: () => achievement,
      );
      
      if (unlockedAchievement.isUnlocked) {
        // 実績解除通知を表示
        if (mounted) {
          AchievementNotificationOverlay.show(context, unlockedAchievement);
          // リストを更新
          ref.invalidate(allAchievementsProvider);
        }
      } else {
        // 解除されなかった場合のエラー表示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('実績の解除に失敗しました。もう一度お試しください。'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error unlocking achievement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 