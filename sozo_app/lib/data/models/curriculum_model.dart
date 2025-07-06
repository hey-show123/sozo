import 'package:freezed_annotation/freezed_annotation.dart';

part 'curriculum_model.freezed.dart';
part 'curriculum_model.g.dart';

@freezed
abstract class Curriculum with _$Curriculum {
  const factory Curriculum({
    required String id,
    required String title,
    String? description,
    required String category,
    @JsonKey(name: 'difficulty_level') required int difficultyLevel,
    @JsonKey(name: 'estimated_hours') int? estimatedHours,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<String> prerequisites,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Curriculum;

  factory Curriculum.fromJson(Map<String, dynamic> json) => _$CurriculumFromJson(json);
}

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    String? curriculumId,
    required String title,
    String? description,
    required int orderIndex,
    required String lessonType,
    double? difficultyScore,
    @Default(30) int estimatedMinutes,
    @Default([]) List<KeyPhrase> keyPhrases,
    @Default([]) List<Dialogue> dialogues,
    @Default([]) List<String> grammarPoints,
    String? culturalNotes,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@freezed
abstract class KeyPhrase with _$KeyPhrase {
  const factory KeyPhrase({
    required String phrase,
    String? phonetic,
    required String meaning,
    String? usage,
    @Default([]) List<String> examples,
    String? audioUrl,
  }) = _KeyPhrase;

  factory KeyPhrase.fromJson(Map<String, dynamic> json) => _$KeyPhraseFromJson(json);
}

@freezed
abstract class Dialogue with _$Dialogue {
  const factory Dialogue({
    required String speaker,
    required String text,
    String? audio,
    String? translation,
  }) = _Dialogue;

  factory Dialogue.fromJson(Map<String, dynamic> json) => _$DialogueFromJson(json);
} 