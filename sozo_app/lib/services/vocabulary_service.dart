import 'package:supabase_flutter/supabase_flutter.dart';

class VocabularyQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  VocabularyQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory VocabularyQuestion.fromJson(Map<String, dynamic> json) {
    return VocabularyQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correct_answer'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}

class VocabularyResult {
  final int totalQuestions;
  final int correctAnswers;
  final List<bool> answers;
  final Duration timeTaken;

  VocabularyResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answers,
    required this.timeTaken,
  });

  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  double get percentage => accuracy * 100;
}

class VocabularyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// レッスンの単語クイズデータを取得
  Future<List<VocabularyQuestion>> getVocabularyQuestions(String lessonId) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select('vocabulary_questions')
          .eq('id', lessonId)
          .single();

      final questionsData = response['vocabulary_questions'] as List<dynamic>?;
      
      if (questionsData == null || questionsData.isEmpty) {
        throw Exception('No vocabulary questions found for this lesson');
      }

      return questionsData
          .map((data) => VocabularyQuestion.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vocabulary questions: $e');
    }
  }

  /// 単語クイズの結果を保存
  Future<void> saveVocabularyResult({
    required String userId,
    required String lessonId,
    required VocabularyResult result,
  }) async {
    try {
      await _supabase.from('pronunciation_sessions').insert({
        'user_id': userId,
        'lesson_id': lessonId,
        'activity_type': 'vocabulary',
        'expected_text': 'vocabulary_quiz',
        'overall_score': result.percentage,
        'accuracy_score': result.percentage,
        'duration_seconds': result.timeTaken.inSeconds,
        'word_scores': {
          'total_questions': result.totalQuestions,
          'correct_answers': result.correctAnswers,
          'answers': result.answers,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save vocabulary result: $e');
    }
  }

  /// 単語クイズの統計情報を取得
  Future<Map<String, dynamic>> getVocabularyStats(String userId) async {
    try {
      final response = await _supabase
          .from('pronunciation_sessions')
          .select('overall_score, created_at')
          .eq('user_id', userId)
          .eq('activity_type', 'vocabulary')
          .order('created_at', ascending: false);

      final sessions = response as List<dynamic>;
      
      if (sessions.isEmpty) {
        return {
          'total_sessions': 0,
          'average_score': 0.0,
          'best_score': 0.0,
          'recent_scores': <double>[],
        };
      }

      final scores = sessions
          .map((session) => (session['overall_score'] as num?)?.toDouble() ?? 0.0)
          .toList();

      return {
        'total_sessions': sessions.length,
        'average_score': scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0.0,
        'best_score': scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0.0,
        'recent_scores': scores.take(10).toList(),
      };
    } catch (e) {
      throw Exception('Failed to fetch vocabulary stats: $e');
    }
  }
} 