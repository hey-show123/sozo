import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/organization_provider.dart';
import 'package:sozo_app/data/models/user_role_model.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends ConsumerWidget {
  final String userId;
  
  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(currentUserRoleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー詳細'),
        elevation: 0,
      ),
      body: userRoleAsync.when(
        data: (userRole) {
          if (userRole == null || userRole.role == UserRole.learner) {
            return const Center(child: Text('アクセス権限がありません'));
          }
          
          return _buildUserDetail(context, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  Widget _buildUserDetail(BuildContext context, WidgetRef ref) {
    // ここでは静的なテストデータを表示
    // 実際の実装では、userIdを使用してSupabaseからユーザーデータを取得
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザー基本情報カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      'U',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ユーザー詳細',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'user@example.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(context, 'レベル', '5', Icons.star),
                      _buildStatItem(context, 'XP', '1,250', Icons.bolt),
                      _buildStatItem(context, 'ストリーク', '7日', Icons.local_fire_department),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 学習統計カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '学習統計',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '完了レッスン',
                          '12',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '総学習時間',
                          '3.5時間',
                          Icons.access_time,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '平均スコア',
                          '87%',
                          Icons.grade,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          '連続学習',
                          '7日',
                          Icons.trending_up,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 週間アクティビティカード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '週間アクティビティ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(context, _getWeeklyData()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 最近の活動カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近の活動',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityList(context),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 80), // 下部の余白
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<Map<String, dynamic>> weeklyData) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.map((data) {
          final height = (data['minutes'] as double) * 3; // 高さの調整
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${data['minutes'].toInt()}分',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height.clamp(10, 150),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['day'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final activities = [
      {
        'title': '基礎英会話 レッスン3完了',
        'time': '2時間前',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': '語彙練習でスコア95%獲得',
        'time': '5時間前',
        'icon': Icons.star,
        'color': Colors.orange,
      },
      {
        'title': '7日連続学習達成！',
        'time': '1日前',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      },
      {
        'title': 'リスニング練習完了',
        'time': '2日前',
        'icon': Icons.headphones,
        'color': Colors.blue,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: (activity['color'] as Color).withOpacity(0.1),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          title: Text(
            activity['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            activity['time'] as String,
            style: TextStyle(color: Colors.grey[600]),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    return [
      {'day': '月', 'minutes': 45.0},
      {'day': '火', 'minutes': 30.0},
      {'day': '水', 'minutes': 60.0},
      {'day': '木', 'minutes': 25.0},
      {'day': '金', 'minutes': 50.0},
      {'day': '土', 'minutes': 35.0},
      {'day': '日', 'minutes': 40.0},
    ];
  }
} 