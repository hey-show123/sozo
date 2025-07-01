import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/presentation/screens/auth/sign_in_screen.dart';
import 'package:sozo_app/presentation/screens/auth/sign_up_screen.dart';
import 'package:sozo_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:sozo_app/presentation/screens/home/home_screen.dart';
import 'package:sozo_app/presentation/screens/curriculum/curriculum_detail_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/lesson_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/dialog_practice_screen.dart';
import 'package:sozo_app/presentation/screens/chat/ai_buddy_screen.dart';
import 'package:sozo_app/presentation/screens/profile/profile_screen.dart';
import 'package:sozo_app/presentation/screens/splash/splash_screen.dart';
import 'package:sozo_app/presentation/screens/test/pronunciation_test_screen.dart';
import 'package:sozo_app/presentation/screens/lessons/lessons_list_screen.dart';
import 'package:sozo_app/presentation/screens/progress/progress_screen.dart';
import 'package:sozo_app/presentation/screens/lesson/lesson_complete_screen.dart';
import 'package:sozo_app/presentation/screens/achievements/achievements_screen.dart';
import 'package:sozo_app/presentation/screens/tutorial/tutorial_screen.dart';
import 'package:sozo_app/presentation/widgets/bottom_navigation.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/lessons',
            builder: (context, state) => const LessonsListScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) {
              return AiBuddyScreen();
            },
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/test/pronunciation',
            builder: (context, state) {
              return const PronunciationTestScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/curriculum/:curriculumId',
        builder: (context, state) {
          final curriculumId = state.pathParameters['curriculumId']!;
          return CurriculumDetailScreen(curriculumId: curriculumId);
        },
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonScreen(lessonId: lessonId);
        },
        routes: [
          GoRoute(
            path: 'dialog',
            builder: (context, state) {
              final lesson = state.extra as LessonModel?;
              if (lesson == null) {
                // フォールバック: エラー画面を表示
                return Scaffold(
                  appBar: AppBar(title: const Text('エラー')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'レッスン情報が見つかりません',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'レッスン画面から再度お試しください',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return DialogPracticeScreen(
                lesson: lesson,
              );
            },
          ),
          GoRoute(
            path: 'ai-conversation',
            builder: (context, state) {
              final lessonId = state.pathParameters['lessonId']!;
              return AiBuddyScreen(lessonId: lessonId);
            },
          ),
          GoRoute(
            path: 'complete',
            builder: (context, state) {
              final lessonId = state.pathParameters['lessonId']!;
              final extra = state.extra;
              if (extra is Map<String, dynamic>) {
                return LessonCompleteScreen(
                  lessonId: lessonId,
                  score: (extra['score'] as num?)?.toDouble() ?? 0.0,
                  sessionCount: (extra['sessionCount'] as int?) ?? 0,
                );
              }
              // エラー時のフォールバック
              return LessonCompleteScreen(
                lessonId: lessonId,
                score: 0.0,
                sessionCount: 0,
              );
            },
          ),
        ],
      ),
    ],
  );
}); 