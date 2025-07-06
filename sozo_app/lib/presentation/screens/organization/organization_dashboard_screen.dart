import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/presentation/providers/organization_provider.dart';
import 'package:sozo_app/data/models/user_role_model.dart';

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
      body: SafeArea(
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
                  title: 'メンバー数',
                  value: '${progressData['totalUsers'] ?? 0}',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'アクティブユーザー',
                  value: '${progressData['activeUsers'] ?? 0}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: '平均レベル',
                  value: '${(progressData['averageLevel'] ?? 0.0).toStringAsFixed(1)}',
                  icon: Icons.bar_chart,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              // 管理機能（admin または super_admin のみ表示）
              if (userRole.role == UserRole.admin || userRole.role == UserRole.superAdmin)
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        _showInviteDialog(context, ref);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add, size: 24),
                          SizedBox(height: 4),
                          Text('招待', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // メンバー一覧
          Text(
            'メンバー一覧',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          if (users.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('メンバーが見つかりません'),
                ),
              ),
            )
          else
            ...users.map((user) => _buildUserCard(context, user)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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
    final avatarUrl = user['avatar_url'] as String?;
    final username = user['username'] as String?;
    final email = user['email'] as String? ?? '';
    final displayName = username?.isNotEmpty == true ? username! : email.split('@').first;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  _getInitials(displayName),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildChip('LV ${user['current_level'] ?? 1}', Colors.blue),
                const SizedBox(width: 8),
                _buildChip('XP ${user['total_xp'] ?? 0}', Colors.green),
                const SizedBox(width: 8),
                _buildChip('${_formatMinutes(user['total_minutes'] ?? 0)}', Colors.orange),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      case UserRole.superAdmin:
        return 'スーパー管理者';
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

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    String selectedRole = 'learner';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいメンバーを招待'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                hintText: 'example@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: '権限',
              ),
              items: const [
                DropdownMenuItem(value: 'learner', child: Text('学習者')),
                DropdownMenuItem(value: 'viewer', child: Text('閲覧者')),
                DropdownMenuItem(value: 'admin', child: Text('管理者')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedRole = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                try {
                  final success = await ref.read(
                    organizationInvitationProvider({
                      'email': emailController.text,
                      'role': selectedRole,
                    }).future,
                  );
                  
                  if (success) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('招待を送信しました')),
                      );
                    }
                  } else {
                    throw Exception('招待の送信に失敗しました');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('エラー: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('招待'),
          ),
        ],
      ),
    );
  }
} 