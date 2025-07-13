import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:sozo_app/presentation/providers/user_stats_provider.dart';
import 'package:sozo_app/presentation/providers/organization_provider.dart' as org;
import 'package:sozo_app/presentation/providers/user_profile_provider.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final hasOrganizationAccessAsync = ref.watch(org.hasOrganizationAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('メニュー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
          ),
        ],
      ),
      body: userStatsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // プロフィール情報
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      userProfileAsync.when(
                        data: (profile) => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: profile?.avatarUrl != null
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                          child: profile?.avatarUrl == null
                              ? Text(
                                  profile?.initials ?? 'G',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade600,
                                  ),
                                )
                              : null,
                        ),
                        loading: () => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircularProgressIndicator(
                            color: Colors.blue.shade600,
                          ),
                        ),
                        error: (_, __) => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'G',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      userProfileAsync.when(
                        data: (profile) => Text(
                          profile?.displayNameOrDefault ?? 'ゲストユーザー',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        loading: () => const Text(
                          '読み込み中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        error: (_, __) => Text(
                          user?.email ?? 'ゲストユーザー',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'レベル ${stats.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 組織管理（権限を持つユーザーのみ表示）
                Column(
                  children: [
                    hasOrganizationAccessAsync.when(
                      data: (hasAccess) => hasAccess
                          ? Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.indigo.shade600,
                                    size: 28,
                                  ),
                                ),
                                title: const Text(
                                  '組織管理',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: const Text('メンバーの学習進捗を確認'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  context.push('/organization/dashboard');
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                
                // チュートリアルテスト（開発用）
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.purple.shade600,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      'チュートリアルテスト',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('チュートリアル画面をプレビュー'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/tutorial');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 通知設定
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Colors.orange.shade600,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      '通知設定',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('リマインダー通知の管理'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/settings/notifications');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 設定
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Colors.grey.shade700,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      '設定',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('アプリの設定'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // 設定画面へ（今後実装）
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }
} 