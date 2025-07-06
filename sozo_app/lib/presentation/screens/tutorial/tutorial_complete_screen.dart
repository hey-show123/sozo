import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TutorialCompleteScreen extends ConsumerStatefulWidget {
  const TutorialCompleteScreen({super.key});

  @override
  ConsumerState<TutorialCompleteScreen> createState() => _TutorialCompleteScreenState();
}

class _TutorialCompleteScreenState extends ConsumerState<TutorialCompleteScreen> {
  late ConfettiController _confettiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // チュートリアル完了を保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);

      // プロフィールのonboarding_completedを更新（存在する場合のみ）
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          // まずprofilesテーブルが存在するか確認
          final profileData = await Supabase.instance.client
              .from('profiles')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();
          
          if (profileData != null) {
            // onboarding_completedカラムが存在する場合のみ更新を試みる
            try {
              await Supabase.instance.client
                  .from('profiles')
                  .update({'onboarding_completed': true})
                  .eq('id', user.id);
            } catch (e) {
              // カラムが存在しない場合は無視
              print('onboarding_completed column may not exist: $e');
            }
          }
        } catch (e) {
          // profilesテーブル関連のエラーは無視
          print('Profile update skipped: $e');
        }
      }

      if (mounted) {
        // ホーム画面へ遷移
        context.go('/home');
      }
    } catch (e) {
      print('Error completing onboarding: $e');
      // 重大なエラーの場合のみ表示
      if (mounted && !e.toString().contains('onboarding_completed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しましたが、続行します'),
            backgroundColor: Colors.orange,
          ),
        );
        // エラーがあってもホーム画面へ遷移
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 背景グラデーション
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                ),
              ),
            ),
            
            // メインコンテンツ
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // プログレスバー
                  LinearProgressIndicator(
                    value: 1.0, // 5/5ステップ完了
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 60),
                  
                  // 完了アイコン
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // タイトル
                  const Text(
                    '準備完了！',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // メッセージ
                  Text(
                    'SOZOで英語学習を\n始めましょう',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // 特典カード
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 40,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ウェルカムボーナス',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+50 XPを獲得しました！',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // 開始ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              '学習を始める',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: (size) {
                  final path = Path();
                  path.addOval(Rect.fromCircle(center: Offset.zero, radius: 4));
                  return path;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 