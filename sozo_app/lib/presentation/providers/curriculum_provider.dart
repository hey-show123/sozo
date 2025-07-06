import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sozo_app/data/models/curriculum_model.dart';
import 'package:sozo_app/data/models/lesson_model.dart' as lesson_model;
import 'package:collection/collection.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// カリキュラムプロバイダー（新しいテーブル構造対応）
final curriculumsProvider = FutureProvider<List<Curriculum>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  final response = await supabase
      .from('curriculums')
      .select()
      .eq('is_active', true)
      .order('difficulty_level', ascending: true);
  
  return (response as List)
      .map((json) => Curriculum.fromJson(json))
      .toList();
});

// 新しいコース構造用のプロバイダー
final coursesProvider = FutureProvider<List<lesson_model.Course>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  final response = await supabase
      .from('courses')
      .select()
      .eq('is_active', true)
      .order('difficulty_level', ascending: true);
  
  return (response as List)
      .map((json) => lesson_model.Course.fromJson(json))
      .toList();
});

// コースに属するモジュールを取得
final modulesProvider = FutureProvider.family<List<lesson_model.Module>, String>(
  (ref, courseId) async {
    final supabase = ref.watch(supabaseProvider);
    
    final response = await supabase
        .from('modules')
        .select()
        .eq('course_id', courseId)
        .eq('is_active', true)
        .order('order_index', ascending: true);
    
    return (response as List)
        .map((json) => lesson_model.Module.fromJson(json))
        .toList();
  },
);

// モジュールに属するレッスンを取得
final moduleLessonsProvider = FutureProvider.family<List<lesson_model.Lesson>, String>(
  (ref, moduleId) async {
    final supabase = ref.watch(supabaseProvider);
    
    final response = await supabase
        .from('lessons')
        .select()
        .eq('module_id', moduleId)
        .order('order', ascending: true);
    
    return (response as List)
        .map((json) => lesson_model.Lesson.fromJson(json))
        .toList();
  },
);

// レッスンの進捗を取得
final lessonProgressProvider = FutureProvider.family<lesson_model.UserLessonProgress?, String>(
  (ref, lessonId) async {
    final supabase = ref.watch(supabaseProvider);
    final user = ref.watch(currentUserProvider);
    
    if (user == null) return null;
    
    final response = await supabase
        .from('user_lesson_progress')
        .select()
        .eq('lesson_id', lessonId)
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (response == null) return null;
    
    return lesson_model.UserLessonProgress.fromJson(response);
  },
);

final curriculumProvider = StateNotifierProvider<CurriculumNotifier, AsyncValue<List<Curriculum>>>((ref) {
  return CurriculumNotifier();
});

final selectedCurriculumProvider = StateProvider<Curriculum?>((ref) => null);

final lessonsProvider = StateNotifierProvider<LessonsNotifier, AsyncValue<List<lesson_model.LessonModel>>>((ref) {
  return LessonsNotifier();
});

class CurriculumNotifier extends StateNotifier<AsyncValue<List<Curriculum>>> {
  CurriculumNotifier() : super(const AsyncValue.loading());

  Future<void> loadCurriculums() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      
      print('Loading curriculums from Supabase...');
      final response = await supabase
          .from('curriculums')
          .select()
          .eq('is_active', true)
          .order('difficulty_level', ascending: true);
      
      print('Curriculums response: $response');
      
      final curriculums = (response as List)
          .map((json) => Curriculum.fromJson(json))
          .toList();
      
      print('Loaded ${curriculums.length} curriculums');
      state = AsyncValue.data(curriculums);
    } catch (e, st) {
      print('Error loading curriculums: $e');
      print('Stack trace: $st');
      state = AsyncValue.error(e, st);
    }
  }

  List<Curriculum> _getSampleCurriculums() {
    // サンプルカリキュラムデータ
    final curriculums = [
      Curriculum(
        id: 'business_english',
        title: 'ビジネス英会話マスター',
        description: 'ビジネスシーンで使える実践的な英会話を学びます',
        difficultyLevel: 3,
        category: 'Business',
        estimatedHours: 40,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Curriculum(
        id: 'daily_conversation',
        title: '日常英会話ベーシック',
        description: '日常生活で必要な基本的な英会話を習得します',
        difficultyLevel: 1,
        category: 'Daily',
        estimatedHours: 30,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Curriculum(
        id: 'pronunciation_master',
        title: '発音改善プログラム',
        description: 'ネイティブのような自然な発音を身につけます',
        difficultyLevel: 2,
        category: 'Pronunciation',
        estimatedHours: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    return curriculums;
  }
}

class LessonsNotifier extends StateNotifier<AsyncValue<List<lesson_model.LessonModel>>> {
  LessonsNotifier() : super(const AsyncValue.loading());

  Future<void> loadLessons(String curriculumId) async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      
      print('Loading lessons for curriculum: $curriculumId');
      final response = await supabase
          .from('lessons')
          .select()
          .eq('curriculum_id', curriculumId)
          .eq('is_active', true)
          .order('order_index', ascending: true);
      
      print('Lessons response: $response');
      
      final lessons = (response as List)
          .map((json) {
            try {
              return lesson_model.LessonModel.fromJson(json);
            } catch (e) {
              print('Error parsing lesson: $json');
              print('Parse error: $e');
              rethrow;
            }
          })
          .toList();
      
      print('Loaded ${lessons.length} lessons');
      state = AsyncValue.data(lessons);
    } catch (error, stackTrace) {
      print('Error loading lessons: $error');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<lesson_model.LessonModel> _getBusinessLessons() {
    return [
      lesson_model.LessonModel(
        id: 'bus_001',
        curriculumId: 'business_english', 
        title: 'ビジネスミーティングの始め方',
        description: 'ビジネスミーティングを適切に開始するための表現を学びます',
        orderIndex: 1,
        type: lesson_model.LessonType.conversation,
        estimatedMinutes: 30,
        difficulty: lesson_model.DifficultyLevel.intermediate,
        objectives: [
          'ビジネスミーティングの開始に必要な基本表現を習得する',
          '適切な挨拶と自己紹介ができるようになる',
          '議題の提示と確認ができるようになる',
        ],
        keyPhrases: [
          const lesson_model.KeyPhrase(
            phrase: "Let's get started with today's meeting",
            meaning: '今日のミーティングを始めましょう',
          ),
        ],
        grammarPoints: [],
        pronunciationFocus: null,
      ),
      lesson_model.LessonModel(
        id: 'bus_002',
        curriculumId: 'business_english',
        title: 'プレゼンテーションの基本',
        description: '効果的なプレゼンテーションのための表現を習得します',
        orderIndex: 2,
        type: lesson_model.LessonType.conversation,
        estimatedMinutes: 45,
        difficulty: lesson_model.DifficultyLevel.intermediate,
        objectives: [
          'プレゼンテーションの構成を理解する',
          '聴衆の注意を引く表現を使えるようになる',
          'データやグラフを説明できるようになる',
        ],
        keyPhrases: [],
        grammarPoints: [],
        pronunciationFocus: null,
      ),
    ];
  }

  List<lesson_model.LessonModel> _getDailyLessons() {
    return [
      lesson_model.LessonModel(
        id: 'daily_001',
        curriculumId: 'daily_conversation',
        title: 'レストランでの注文',
        description: 'レストランで使える実用的な表現を学びます',
        orderIndex: 1,
        type: lesson_model.LessonType.conversation,
        estimatedMinutes: 20,
        difficulty: lesson_model.DifficultyLevel.beginner,
        objectives: [
          'レストランでの基本的な注文ができるようになる',
          'メニューについて質問できるようになる',
          '食事の好みを伝えられるようになる',
        ],
        keyPhrases: [
          const lesson_model.KeyPhrase(
            phrase: "Could I see the menu, please?",
            meaning: 'メニューを見せていただけますか？',
          ),
        ],
        grammarPoints: [],
        pronunciationFocus: null,
      ),
      lesson_model.LessonModel(
        id: 'daily_002',
        curriculumId: 'daily_conversation',
        title: '道を尋ねる・教える',
        description: '道案内に必要な表現を習得します',
        orderIndex: 2,
        type: lesson_model.LessonType.conversation,
        estimatedMinutes: 25,
        difficulty: lesson_model.DifficultyLevel.beginner,
        objectives: [
          '道を尋ねる丁寧な表現を使えるようになる',
          '方向や場所を説明できるようになる',
          '距離や時間を伝えられるようになる',
        ],
        keyPhrases: [],
        grammarPoints: [],
        pronunciationFocus: null,
      ),
    ];
  }

  List<lesson_model.LessonModel> _getPronunciationLessons() {
    return [
      lesson_model.LessonModel(
        id: 'pron_001',
        curriculumId: 'pronunciation_master',
        title: 'L と R の発音',
        description: '日本人が苦手なLとRの発音を克服します',
        orderIndex: 1,
        type: lesson_model.LessonType.pronunciation,
        estimatedMinutes: 15,
        difficulty: lesson_model.DifficultyLevel.intermediate,
        objectives: [
          'LとRの音の違いを理解する',
          '正しい舌の位置を習得する',
          '単語と文章でLとRを正確に発音できるようになる',
        ],
        keyPhrases: [],
        grammarPoints: [],
        pronunciationFocus: const lesson_model.PronunciationFocus(
          targetSounds: ['l', 'r'],
          words: ['light', 'right', 'fly', 'fry', 'lead', 'read'],
          sentences: [
            'The light is really bright.',
            'Please read the red book.',
            'I like to fly to foreign countries.',
          ],
          tips: {
            'L音': '舌先を上の前歯の後ろにつける',
            'R音': '舌を口の中で巻いて、どこにも触れない',
          },
        ),
      ),
    ];
  }
}

// ユーザーの進捗状況
final userProgressProvider = FutureProvider<Map<String, lesson_model.UserLessonProgress>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return {};
  
  final response = await supabase
      .from('user_lesson_progress')
      .select()
      .eq('user_id', user.id);
  
  final progressList = (response as List)
      .map((json) => lesson_model.UserLessonProgress.fromJson(json))
      .toList();
  
  return {
    for (final progress in progressList) progress.lessonId: progress,
  };
});

 