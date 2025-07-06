import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/presentation/providers/organization_provider.dart';
import 'package:sozo_app/data/models/user_role_model.dart';
import 'package:intl/intl.dart';

class OrganizationDashboardScreen extends ConsumerWidget {
  const OrganizationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoleAsync = ref.watch(currentUserRoleProvider);
    final progressDataAsync = ref.watch(organizationLearningProgressProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('組織ダッシュボード'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(organizationLearningProgressProvider);
        },
        child: userRoleAsync.when(
          data: (userRole) {
            if (userRole == null) {
              return const Center(child: Text('アクセス権限がありません'));
            }
            
            if (userRole.role == UserRole.learner) {
              return const Center(child: Text('この機能は管理者・閲覧者のみ利用できます'));
            }
            
            return progressDataAsync.when(
              data: (progressData) => _buildDashboard(context, ref, userRole, progressData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('エラーが発生しました: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(organizationLearningProgressProvider),
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('エラーが発生しました: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    UserOrganizationRole userRole,
    Map<String, dynamic> progressData,
  ) {
    final users = (progressData['users'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 組織情報
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        userRole.organization?.name ?? '組織名不明',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '現在のロール: ${_getRoleDisplayName(userRole.role)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 統計カード
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  '総メンバー数',
                  '${progressData['totalUsers'] ?? 0}人',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'アクティブ',
                  '${progressData['activeUsers'] ?? 0}人',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  '平均レベル',
                  '${(progressData['averageLevel'] as num? ?? 0).toStringAsFixed(1)}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // メンバー一覧
          Text(
            'メンバー一覧',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          if (users.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'メンバーがいません',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(context, user);
              },
            ),
          
          const SizedBox(height: 80), // 下部の余白
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user) {
    final completedLessons = user['completed_lessons'] ?? 0;
    final totalMinutes = user['total_minutes'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            _getInitials(user['username'] ?? user['email'] ?? '?'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user['username'] ?? user['email']?.toString().split('@')[0] ?? '不明',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip('Lv.${user['current_level'] ?? 1}', Colors.blue),
                const SizedBox(width: 4),
                _buildChip('${user['total_xp'] ?? 0}XP', Colors.green),
                const SizedBox(width: 4),
                _buildChip('${user['streak_count'] ?? 0}日', Colors.orange),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '完了レッスン: $completedLessons',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '学習時間: ${_formatMinutes(totalMinutes)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go('/organization/user/${user['user_id']}');
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '管理者';
      case UserRole.viewer:
        return '閲覧者';
      case UserRole.learner:
        return '学習者';
    }
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}分';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}時間${remainingMinutes}分';
    }
  }
} 