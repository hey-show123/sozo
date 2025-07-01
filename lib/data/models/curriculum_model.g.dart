// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Curriculum _$CurriculumFromJson(Map<String, dynamic> json) => _Curriculum(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      difficultyLevel: (json['difficulty_level'] as num).toInt(),
      estimatedHours: (json['estimated_hours'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CurriculumToJson(_Curriculum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'difficulty_level': instance.difficultyLevel,
      'estimated_hours': instance.estimatedHours,
      'image_url': instance.imageUrl,
      'prerequisites': instance.prerequisites,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_Lesson _$LessonFromJson(Map<String, dynamic> json) => _Lesson(
      id: json['id'] as String,
      curriculumId: json['curriculumId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: (json['orderIndex'] as num).toInt(),
      lessonType: json['lessonType'] as String,
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble(),
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 30,
      keyPhrases: (json['keyPhrases'] as List<dynamic>?)
              ?.map((e) => KeyPhrase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dialogues: (json['dialogues'] as List<dynamic>?)
              ?.map((e) => Dialogue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      grammarPoints: (json['grammarPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      culturalNotes: json['culturalNotes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LessonToJson(_Lesson instance) => <String, dynamic>{
      'id': instance.id,
      'curriculumId': instance.curriculumId,
      'title': instance.title,
      'description': instance.description,
      'orderIndex': instance.orderIndex,
      'lessonType': instance.lessonType,
      'difficultyScore': instance.difficultyScore,
      'estimatedMinutes': instance.estimatedMinutes,
      'keyPhrases': instance.keyPhrases,
      'dialogues': instance.dialogues,
      'grammarPoints': instance.grammarPoints,
      'culturalNotes': instance.culturalNotes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_KeyPhrase _$KeyPhraseFromJson(Map<String, dynamic> json) => _KeyPhrase(
      phrase: json['phrase'] as String,
      phonetic: json['phonetic'] as String?,
      meaning: json['meaning'] as String,
      usage: json['usage'] as String?,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$KeyPhraseToJson(_KeyPhrase instance) =>
    <String, dynamic>{
      'phrase': instance.phrase,
      'phonetic': instance.phonetic,
      'meaning': instance.meaning,
      'usage': instance.usage,
      'examples': instance.examples,
      'audioUrl': instance.audioUrl,
    };

_Dialogue _$DialogueFromJson(Map<String, dynamic> json) => _Dialogue(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      audio: json['audio'] as String?,
      translation: json['translation'] as String?,
    );

Map<String, dynamic> _$DialogueToJson(_Dialogue instance) => <String, dynamic>{
      'speaker': instance.speaker,
      'text': instance.text,
      'audio': instance.audio,
      'translation': instance.translation,
    };
