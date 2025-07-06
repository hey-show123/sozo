import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('SplashScreen: initState called');
    // 初期化処理を少し遅延させて、Supabaseの初期化が完了するのを待つ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndOnboarding();
    });
  }
  
  Future<void> _checkAuthAndOnboarding() async {
    print('SplashScreen: _checkAuthAndOnboarding started');
    
    try {
      // Supabaseのセッション復元を待つ
      final supabase = Supabase.instance.client;
      
      // セッションの復元を確実に行うため、少し待機
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 現在のセッションを確認
      final currentSession = supabase.auth.currentSession;
      
      if (currentSession != null) {
        print('SplashScreen: Session found → ユーザーはログイン済み');
        print('SplashScreen: User email: ${currentSession.user.email}');
        print('SplashScreen: Session expires at: ${currentSession.expiresAt}');
        
        // セッションが有効期限内かチェック
        if (currentSession.expiresAt != null && 
            DateTime.now().millisecondsSinceEpoch / 1000 < currentSession.expiresAt!) {
          await _navigateAfterLogin(currentSession);
          return;
        } else {
          print('SplashScreen: Session expired, navigating to sign-in');
          if (mounted) {
            context.go('/sign-in');
          }
          return;
        }
      }
      
      print('SplashScreen: No session found, checking auth state stream...');
      
      // セッションがない場合は、認証状態のストリームを監視
      // 最大3秒待機
      int attempts = 0;
      while (attempts < 6 && mounted) {
        final authState = ref.read(authStateProvider);
        
        final session = authState.when(
          data: (state) => state.session,
          loading: () => null,
          error: (_, __) => null,
        );
        
        if (session != null) {
          print('SplashScreen: Session found in auth stream');
          await _navigateAfterLogin(session);
          return;
        }
        
        attempts++;
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // タイムアウト：ログイン画面へ
      print('SplashScreen: No session found after waiting, navigating to sign-in');
      if (mounted) {
        context.go('/sign-in');
      }
      
    } catch (e) {
      print('SplashScreen: Error during auth check: $e');
      if (mounted) {
        context.go('/sign-in');
      }
    }
  }

  Future<void> _navigateAfterLogin(Session session) async {
    final supabase = Supabase.instance.client;
    final userId = session.user.id;
    print('SplashScreen: _navigateAfterLogin user=$userId');

    try {
      // onboarding_completedカラムが存在しない可能性があるため、
      // エラーが発生した場合は無視して進む
      bool onboardingCompleted = true; // デフォルトはtrue
      
      try {
        final profile = await supabase
            .from('profiles')
            .select('onboarding_completed')
            .eq('id', userId)
            .single();
        
        onboardingCompleted = profile['onboarding_completed'] ?? true;
      } catch (e) {
        print('SplashScreen: Profile fetch error (ignoring): $e');
        // エラーが発生した場合はonboardingCompletedをtrueとして扱う
      }

      if (!mounted) return;

      if (onboardingCompleted) {
        // チュートリアルの完了状態をチェック
        final prefs = await SharedPreferences.getInstance();
        final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
        
        if (!tutorialCompleted) {
          print('SplashScreen: Tutorial not completed, navigating to /tutorial');
          context.go('/tutorial');
        } else {
          print('SplashScreen: Navigating to /home');
          context.go('/home');
        }
      } else {
        print('SplashScreen: Navigating to /onboarding');
        context.go('/onboarding');
      }
    } catch (e) {
      print('SplashScreen: Unexpected error: $e');
      if (mounted) {
        // エラー時もチュートリアルチェックを行う
        final prefs = await SharedPreferences.getInstance();
        final tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;
        
        if (!tutorialCompleted) {
          context.go('/tutorial');
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'SOZO',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'AIと一緒に英語を話そう',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
} 