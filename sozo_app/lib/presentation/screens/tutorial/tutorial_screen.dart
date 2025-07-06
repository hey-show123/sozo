import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sozo_app/services/progress_service.dart';
import 'package:sozo_app/presentation/screens/tutorial/tutorial_username_screen.dart';

class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('TutorialScreen: Building widget');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ロゴ
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    size: 60,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 40),
                
                // タイトル
                const Text(
                  'SOZOへようこそ！',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // サブタイトル
                const Text(
                  'AIと一緒に英語を話す\n新しい学習体験',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                
                // 始めるボタン
                ElevatedButton(
                  onPressed: () {
                    // ユーザー名入力画面へ遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TutorialUsernameScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                  child: const Text(
                    'チュートリアルを始める',
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // スキップボタン
                TextButton(
                  onPressed: () async {
                    // チュートリアル完了を保存
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('tutorial_completed', true);
                    
                    // ホーム画面へ
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                  child: Text(
                    'スキップ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 