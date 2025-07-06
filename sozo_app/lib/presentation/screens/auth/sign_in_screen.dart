import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/animated_card.dart';
import '../../../core/theme/app_theme.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      print('Attempting to sign in with email: ${_emailController.text.trim()}');
      try {
        await ref.read(authNotifierProvider.notifier).signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        print('Sign in completed');
      } catch (e) {
        print('Sign in error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous?.isLoading == true) {
            context.go('/home');
          }
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラー: ${error.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ロゴとタイトル
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.secondaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.language,
                            size: 50,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text(
                          'SOZO',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.2, duration: 500.ms),
                        const SizedBox(height: 8),
                        Text(
                          '英語学習の新しい形',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.primaryColor.withOpacity(0.7),
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // フォームカード
                    AnimatedCard(
                      padding: const EdgeInsets.all(32),
                      borderRadius: BorderRadius.circular(24),
                      animationDelay: 600.ms,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'メールアドレス',
                              prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'メールアドレスを入力してください';
                              }
                              if (!value.contains('@')) {
                                return '有効なメールアドレスを入力してください';
                              }
                              return null;
                            },
                          ).animate()
                            .fadeIn(duration: 400.ms, delay: 800.ms)
                            .slideX(begin: -0.1, duration: 400.ms),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'パスワード',
                              prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppTheme.primaryColor.withOpacity(0.6),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'パスワードを入力してください';
                              }
                              if (value.length < 8) {
                                return 'パスワードは8文字以上である必要があります';
                              }
                              return null;
                            },
                          ).animate()
                            .fadeIn(duration: 400.ms, delay: 900.ms)
                            .slideX(begin: -0.1, duration: 400.ms),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: パスワードリセット画面への遷移
                              },
                              child: Text(
                                'パスワードを忘れた方',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ).animate()
                            .fadeIn(duration: 400.ms, delay: 1000.ms),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedButton(
                      onPressed: authState.isLoading ? null : _signIn,
                      width: double.infinity,
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'サインイン',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 1100.ms)
                      .slideY(begin: 0.2, duration: 400.ms),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(authNotifierProvider.notifier)
                                  .signInWithGoogle();
                            },
                      width: double.infinity,
                      isOutlined: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Googleでサインイン',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 1200.ms)
                      .slideY(begin: 0.2, duration: 400.ms),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'アカウントをお持ちでない方は',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/sign-up');
                          },
                          child: Text(
                            '新規登録',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                      .fadeIn(duration: 400.ms, delay: 1300.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 