import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
abstract class Course with _$Course {
  const factory Course({
    required String id,
    required String title,
    required String description,
    required int difficultyLevel,
    required String category,
    String? imageUrl,
    int? estimatedHours,
    @Default([]) List<String> prerequisites,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@freezed
abstract class Module with _$Module {
  const factory Module({
    required String id,
    required String courseId,
    required String title,
    String? description,
    required int orderIndex,
    @Default({}) Map<String, dynamic> unlockRequirements,
    int? estimatedMinutes,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Module;

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);
}

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    String? moduleId,
    required String title,
    String? description,
    required int level,
    int? order,
    String? lessonType,
    double? difficultyScore,
    @Default([]) List<String> targetPhrases,
    @Default([]) List<String> grammarPoints,
    String? culturalNotes,
    DateTime? createdAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@freezed
abstract class LessonActivity with _$LessonActivity {
  const factory LessonActivity({
    required String id,
    required String lessonId,
    required String activityType,
    required int orderIndex,
    required Map<String, dynamic> content,
    String? audioUrl,
    int? estimatedMinutes,
    @Default({}) Map<String, dynamic> successCriteria,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _LessonActivity;

  factory LessonActivity.fromJson(Map<String, dynamic> json) => 
      _$LessonActivityFromJson(json);
}

@freezed
abstract class UserLessonProgress with _$UserLessonProgress {
  const factory UserLessonProgress({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'lesson_id') required String lessonId,
    @Default('not_started') String status,
    int? score,
    @JsonKey(name: 'attempts_count') @Default(0) int attemptsCount,
    @JsonKey(name: 'best_score') double? bestScore,
    @JsonKey(name: 'total_time_spent') @Default(0) int totalTimeSpent,
    @JsonKey(name: 'mastery_score') double? masteryScore,
    @JsonKey(name: 'mastery_level') @Default(0) int masteryLevel,
    @JsonKey(name: 'last_attempt_at') DateTime? lastAttemptAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserLessonProgress;

  factory UserLessonProgress.fromJson(Map<String, dynamic> json) => 
      _$UserLessonProgressFromJson(json);
}

@freezed
abstract class PronunciationSession with _$PronunciationSession {
  const factory PronunciationSession({
    required String id,
    required String userId,
    String? lessonId,
    required String audioFileUrl,
    String? transcriptExpected,
    String? transcriptActual,
    double? overallScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    Map<String, dynamic>? wordLevelScores,
    Map<String, dynamic>? phonemeAnalysis,
    String? feedbackSummary,
    @Default([]) List<String> improvementSuggestions,
    int? sessionDuration,
    DateTime? createdAt,
  }) = _PronunciationSession;

  factory PronunciationSession.fromJson(Map<String, dynamic> json) => 
      _$PronunciationSessionFromJson(json);
}

@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    String? description,
    required String category,
    String? badgeIconUrl,
    @Default('common') String rarity,
    @Default(0) int xpReward,
    required Map<String, dynamic> unlockCriteria,
    @Default(false) bool isHidden,
    DateTime? createdAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) => 
      _$AchievementFromJson(json);
}

@freezed
abstract class UserAchievement with _$UserAchievement {
  const factory UserAchievement({
    String? id,
    required String userId,
    required String achievementId,
    required DateTime unlockedAt,
    Map<String, dynamic>? progressData,
  }) = _UserAchievement;

  factory UserAchievement.fromJson(Map<String, dynamic> json) => 
      _$UserAchievementFromJson(json);
}

@freezed
abstract class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    @JsonKey(name: 'curriculum_id') required String curriculumId,
    required String title,
    @Default('') String description,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    @JsonKey(fromJson: _lessonTypeFromJson) required LessonType type,
    @JsonKey(name: 'estimated_minutes') @Default(30) int estimatedMinutes,
    @JsonKey(fromJson: _difficultyFromJson) required DifficultyLevel difficulty,
    @JsonKey(fromJson: _objectivesFromJson) @Default([]) List<String> objectives,
    @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson) @Default([]) List<KeyPhrase> keyPhrases,
    @JsonKey(fromJson: _dialoguesFromJson) @Default([]) List<Map<String, dynamic>> dialogues,
    @JsonKey(name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson) @Default([]) List<Map<String, dynamic>> vocabularyQuestions,
    @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson) @Default([]) List<GrammarPoint> grammarPoints,
    @JsonKey(name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson) PronunciationFocus? pronunciationFocus,
    @JsonKey(name: 'character_id', fromJson: _characterIdFromJson) @Default('sarah') String characterId,
    @Default(false) bool isCompleted,
    @Default(0) double completionRate,
    DateTime? lastAccessedAt,
    Map<String, dynamic>? metadata,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}

// カスタム変換関数
LessonType _lessonTypeFromJson(dynamic value) {
  if (value == null) return LessonType.conversation;
  if (value is String) {
    switch (value) {
      case 'conversation':
        return LessonType.conversation;
      case 'pronunciation':
        return LessonType.pronunciation;
      case 'vocabulary':
        return LessonType.vocabulary;
      case 'grammar':
        return LessonType.grammar;
      case 'review':
        return LessonType.review;
      default:
        return LessonType.conversation;
    }
  }
  return LessonType.conversation;
}

DifficultyLevel _difficultyFromJson(dynamic value) {
  if (value == null) return DifficultyLevel.beginner;
  if (value is String) {
    switch (value) {
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'elementary':
        return DifficultyLevel.elementary;
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }
  return DifficultyLevel.beginner;
}

List<String> _objectivesFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

List<KeyPhrase> _keyPhrasesFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => KeyPhrase.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

List<Map<String, dynamic>> _dialoguesFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e as Map<String, dynamic>).toList();
  }
  return [];
}

List<Map<String, dynamic>> _vocabularyQuestionsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => e as Map<String, dynamic>).toList();
  }
  return [];
}

List<GrammarPoint> _grammarPointsFromJson(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) => GrammarPoint.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

PronunciationFocus? _pronunciationFocusFromJson(dynamic value) {
  if (value == null) return null;
  if (value is List && value.isEmpty) return null;
  if (value is Map<String, dynamic>) {
    return PronunciationFocus.fromJson(value);
  }
  return null;
}

String _characterIdFromJson(dynamic value) {
  if (value == null) return 'sarah'; // デフォルトはSarah
  if (value is String) {
    // 利用可能なキャラクターIDかチェック
    const availableIds = ['sarah', 'maya', 'alex', 'emma'];
    if (availableIds.contains(value)) {
      return value;
    }
  }
  return 'sarah'; // 無効な値の場合はデフォルト
}

enum LessonType {
  @JsonValue('conversation')
  conversation,
  @JsonValue('pronunciation')
  pronunciation,
  @JsonValue('vocabulary')
  vocabulary,
  @JsonValue('grammar')
  grammar,
  @JsonValue('review')
  review,
}

enum DifficultyLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('elementary')
  elementary,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

@freezed
abstract class KeyPhrase with _$KeyPhrase {
  const factory KeyPhrase({
    required String phrase,
    required String meaning,
    @JsonKey(name: 'phonetic') String? pronunciation,
    @JsonKey(name: 'audio_url') String? audioUrl,
  }) = _KeyPhrase;

  factory KeyPhrase.fromJson(Map<String, dynamic> json) =>
      _$KeyPhraseFromJson(json);
}

@freezed
abstract class GrammarPoint with _$GrammarPoint {
  const factory GrammarPoint({
    required String name,
    required String explanation,
    required String structure,
    required List<String> examples,
    List<String>? commonMistakes,
  }) = _GrammarPoint;

  factory GrammarPoint.fromJson(Map<String, dynamic> json) =>
      _$GrammarPointFromJson(json);
}

@freezed
abstract class PronunciationFocus with _$PronunciationFocus {
  const factory PronunciationFocus({
    required List<String> targetSounds,
    required List<String> words,
    required List<String> sentences,
    Map<String, String>? tips,
  }) = _PronunciationFocus;

  factory PronunciationFocus.fromJson(Map<String, dynamic> json) =>
      _$PronunciationFocusFromJson(json);
} 