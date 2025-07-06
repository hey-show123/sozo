import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/data/models/lesson_model.dart';
import 'package:sozo_app/presentation/screens/lesson/dialog_practice_screen.dart';
import 'tutorial_complete_screen.dart';

class TutorialDialogWrapperScreen extends ConsumerStatefulWidget {
  const TutorialDialogWrapperScreen({super.key});

  @override
  ConsumerState<TutorialDialogWrapperScreen> createState() => _TutorialDialogWrapperScreenState();
}

class _TutorialDialogWrapperScreenState extends ConsumerState<TutorialDialogWrapperScreen> {
  late LessonModel tutorialLesson;
  
  @override
  void initState() {
    super.initState();
    // チュートリアル用の特別なレッスンモデルを初期化
    tutorialLesson = LessonModel(
    id: '00000000-0000-0000-0000-000000000001', // 特別なUUID形式のID
    curriculumId: '00000000-0000-0000-0000-000000000000', // 特別なUUID形式のID
    title: 'Welcome to SOZO',
    description: 'Practice greeting your SOZO instructor',
    orderIndex: 0,
    type: LessonType.conversation,
    difficulty: DifficultyLevel.beginner,
    estimatedMinutes: 5,
    keyPhrases: [
      KeyPhrase(
        phrase: "Thank you! I'm excited to start learning.",
        meaning: '感謝の気持ちと学習への意欲を表現（ありがとうございます！学習を始めるのが楽しみです。）',
      ),
      KeyPhrase(
        phrase: "I look forward to working with you!",
        meaning: '協力関係への期待を表現（よろしくお願いします！）',
      ),
    ],
    dialogues: [
      {
        'speaker': 'Customer',  // 先生役
        'text': "Welcome to SOZO! I'm Sarah, your English learning coordinator.",
        'japanese': 'SOZOへようこそ！私はサラ、あなたの英語学習コーディネーターです。',
        'audioUrl': null,
      },
      {
        'speaker': 'Staff',  // 生徒役（ユーザー）
        'text': "Thank you! I'm excited to start learning.",
        'japanese': 'ありがとうございます！学習を始めるのが楽しみです。',
        'audioUrl': null,
      },
      {
        'speaker': 'Customer',
        'text': "That's wonderful! We're here to support your English journey.",
        'japanese': '素晴らしいですね！私たちはあなたの英語学習の旅をサポートします。',
        'audioUrl': null,
      },
      {
        'speaker': 'Staff',
        'text': "I look forward to working with you!",
        'japanese': 'よろしくお願いします！',
        'audioUrl': null,
      },
      {
        'speaker': 'Customer',
        'text': "Let's make your English learning fun and effective! See you in class!",
        'japanese': '楽しく効果的な英語学習にしましょう！クラスでお会いしましょう！',
        'audioUrl': null,
      },
    ],
  );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 既存のDialogPracticeScreenを使用
            DialogPracticeScreen(
              lesson: tutorialLesson,
              onComplete: () {
                // チュートリアル完了画面へ遷移
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const TutorialCompleteScreen(),
                  ),
                );
              },
            ),
            
            // チュートリアル用のプログレスバーをオーバーレイ
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.white.withOpacity(0.9),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 0.9, // 4.5/5ステップ
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blue.shade600,
                        minHeight: 4,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'チュートリアル: SOZOの先生と会話してみましょう',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 