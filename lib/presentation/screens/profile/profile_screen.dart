import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:sozo_app/presentation/providers/user_stats_provider.dart';
import 'package:sozo_app/services/achievement_service.dart';
import 'package:sozo_app/services/azure_speech_service.dart';
import 'package:sozo_app/core/utils/platform_utils.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _testAzurePronunciation(BuildContext context, WidgetRef ref) async {
    if (!PlatformUtils.isFileSystemSupported) {
      _showWebAzureTestDialog(context, ref);
      return;
    }
    
    // 進行状況ダイアログを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Azure発音評価をテスト中...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // テスト音声ファイルを読み込む
      final bytes = await rootBundle.load('assets/test_audio.wav');
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/test_audio_azure.wav');
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      // Azure Speech Serviceを使って評価
      final azureService = ref.read(azureSpeechServiceProvider);
      const expectedText = "Good morning. I would like to do a treatment as well";
      
      final result = await azureService.assessPronunciation(
        audioFile: tempFile,
        expectedText: expectedText,
        language: 'en-US',
      );

      // 一時ファイルを削除
      try {
        await tempFile.delete();
      } catch (_) {}

      // ダイアログを閉じる
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 結果を表示
      if (result != null && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Azure発音評価結果'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('期待されるテキスト:\n$expectedText\n'),
                  Text('認識されたテキスト:\n${result.displayText}\n'),
                  const SizedBox(height: 16),
                  Text('総合スコア: ${result.overallScore.toInt()}%'),
                  Text('正確さ: ${result.accuracyScore.toInt()}%'),
                  Text('流暢さ: ${result.fluencyScore.toInt()}%'),
                  Text('完全性: ${result.completenessScore.toInt()}%'),
                  
                  if (result.wordScores != null && result.wordScores!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('単語ごとの評価:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...result.wordScores!.map((word) => Text(
                      '${word.word}: ${word.accuracyScore.toInt()}% ${word.errorType != "None" ? "(${word.errorType})" : ""}',
                    )),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('発音評価結果を取得できませんでした'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ダイアログを閉じる
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWebAzureTestDialog(BuildContext context, WidgetRef ref) {
    // Web版でのモック評価結果を表示
    const expectedText = "Good morning. I would like to do a treatment as well";
    final mockResult = PronunciationAssessmentResult.fromMockData(expectedText: expectedText);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.science, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Azure発音評価 (Web版デモ)'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Web版では模擬結果を表示しています',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('期待されるテキスト:\n$expectedText\n'),
              Text('認識されたテキスト:\n${mockResult.displayText}\n'),
              const SizedBox(height: 16),
              Text('総合スコア: ${mockResult.overallScore.toInt()}%'),
              Text('正確さ: ${mockResult.accuracyScore.toInt()}%'),
              Text('流暢さ: ${mockResult.fluencyScore.toInt()}%'),
              Text('完全性: ${mockResult.completenessScore.toInt()}%'),
              
              if (mockResult.wordScores != null && mockResult.wordScores!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('単語ごとの評価:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...mockResult.wordScores!.map((word) => Text(
                  '${word.word}: ${word.accuracyScore.toInt()}% ${word.errorType != "None" ? "(${word.errorType})" : ""}',
                )),
              ],
              
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '💡 実際のAzure発音評価を試すには、スマートフォンアプリ版をご利用ください。',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final achievementsAsync = ref.watch(allAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
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
                      CircleAvatar(
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
                      const SizedBox(height: 12),
                      Text(
                        user?.email ?? 'ゲストユーザー',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                
                // 学習統計
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '学習統計',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.local_fire_department,
                              label: 'ストリーク',
                              value: '${stats.currentStreak}日',
                              color: Colors.orange,
                            ),
                            _StatItem(
                              icon: Icons.star,
                              label: '総XP',
                              value: '${stats.totalXP}',
                              color: Colors.amber,
                            ),
                            _StatItem(
                              icon: Icons.timer,
                              label: '今日の学習',
                              value: '${stats.todayMinutes}分',
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 実績
                achievementsAsync.when(
                  data: (achievements) {
                    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
                    final totalCount = achievements.length;
                    
                    return Card(
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
                            Icons.emoji_events,
                            color: Colors.purple.shade600,
                            size: 28,
                          ),
                        ),
                        title: const Text(
                          '実績',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('$unlockedCount / $totalCount 個を達成'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.push('/achievements');
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                
                const SizedBox(height: 16),
                
                // 発音テスト
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
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.record_voice_over,
                        color: Colors.blue.shade600,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      '発音テスト',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('発音スキルをチェック'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push('/test/pronunciation');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Azure発音評価テスト（開発用）
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
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.science,
                        color: Colors.red.shade600,
                        size: 28,
                      ),
                    ),
                    title: const Text(
                      'Azure発音評価テスト',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('テスト音声でAzure APIをテスト'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      _testAzurePronunciation(context, ref);
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
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
                    subtitle: const Text('通知・音声設定など'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // 設定画面へ
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
} 