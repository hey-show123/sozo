import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/organization_provider.dart';
import 'package:sozo_app/data/models/user_role_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/organization/dashboard');
            }
          },
        ),
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
    // モックデータ（実際のデータベースクエリが必要）
    final mockUser = {
      'username': 'ユーザー詳細',
      'email': 'user@example.com',
      'current_level': 3,
      'total_xp': 1500,
      'streak_count': 7,
      'total_minutes': 440,
    };

    final mockWeeklyActivity = [
      {'day': '月', 'minutes': 45},
      {'day': '火', 'minutes': 60},
      {'day': '水', 'minutes': 30},
      {'day': '木', 'minutes': 75},
      {'day': '金', 'minutes': 90},
      {'day': '土', 'minutes': 0},
      {'day': '日', 'minutes': 40},
    ];

    final mockRecentLessons = [
      {
        'title': 'ビジネス英会話 - 会議',
        'status': 'completed',
        'score': 95.0,
        'completed_at': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'title': '日常会話 - ショッピング',
        'status': 'completed',
        'score': 88.0,
        'completed_at': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'title': '発音練習 - 基礎',
        'status': 'in_progress',
        'score': 72.0,
        'completed_at': null,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザー情報カード
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      mockUser['username']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mockUser['username']?.toString() ?? 'ユーザー名未設定',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mockUser['email']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusChip('LV ${mockUser['current_level']}', Colors.blue),
                            const SizedBox(width: 8),
                            _buildStatusChip('${mockUser['streak_count']}日連続', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 学習統計
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '総XP',
                  '${mockUser['total_xp']}',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '学習時間',
                  '${_formatMinutes(mockUser['total_minutes'] as int)}',
                  Icons.timer,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 週間アクティビティ
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '週間アクティビティ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: mockWeeklyActivity.map((data) {
                        final minutes = data['minutes'] as int;
                        final maxMinutes = 90; // 最大値を設定
                        final height = (minutes / maxMinutes * 80).clamp(4.0, 80.0);
                        
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${minutes}分',
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 20,
                              height: height,
                              decoration: BoxDecoration(
                                color: minutes > 0 ? Colors.blue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['day'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 最近のレッスン
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '最近のレッスン',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...mockRecentLessons.map((lesson) => _buildLessonItem(lesson)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildLessonItem(Map<String, dynamic> lesson) {
    final status = lesson['status'] as String;
    final isCompleted = status == 'completed';
    final completedAt = lesson['completed_at'] as DateTime?;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      isCompleted ? '完了' : '進行中',
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      Text(
                        'スコア: ${lesson['score']}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                if (completedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MM/dd HH:mm').format(completedAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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