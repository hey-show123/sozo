// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Course _$CourseFromJson(Map<String, dynamic> json) => _Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficultyLevel: (json['difficultyLevel'] as num).toInt(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      estimatedHours: (json['estimatedHours'] as num?)?.toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CourseToJson(_Course instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'difficultyLevel': instance.difficultyLevel,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'estimatedHours': instance.estimatedHours,
      'prerequisites': instance.prerequisites,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_Module _$ModuleFromJson(Map<String, dynamic> json) => _Module(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: (json['orderIndex'] as num).toInt(),
      unlockRequirements:
          json['unlockRequirements'] as Map<String, dynamic>? ?? const {},
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ModuleToJson(_Module instance) => <String, dynamic>{
      'id': instance.id,
      'courseId': instance.courseId,
      'title': instance.title,
      'description': instance.description,
      'orderIndex': instance.orderIndex,
      'unlockRequirements': instance.unlockRequirements,
      'estimatedMinutes': instance.estimatedMinutes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_Lesson _$LessonFromJson(Map<String, dynamic> json) => _Lesson(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      level: (json['level'] as num).toInt(),
      order: (json['order'] as num?)?.toInt(),
      lessonType: json['lessonType'] as String?,
      difficultyScore: (json['difficultyScore'] as num?)?.toDouble(),
      targetPhrases: (json['targetPhrases'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      grammarPoints: (json['grammarPoints'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      culturalNotes: json['culturalNotes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LessonToJson(_Lesson instance) => <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'description': instance.description,
      'level': instance.level,
      'order': instance.order,
      'lessonType': instance.lessonType,
      'difficultyScore': instance.difficultyScore,
      'targetPhrases': instance.targetPhrases,
      'grammarPoints': instance.grammarPoints,
      'culturalNotes': instance.culturalNotes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_LessonActivity _$LessonActivityFromJson(Map<String, dynamic> json) =>
    _LessonActivity(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      activityType: json['activityType'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      content: json['content'] as Map<String, dynamic>,
      audioUrl: json['audioUrl'] as String?,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      successCriteria:
          json['successCriteria'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LessonActivityToJson(_LessonActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'activityType': instance.activityType,
      'orderIndex': instance.orderIndex,
      'content': instance.content,
      'audioUrl': instance.audioUrl,
      'estimatedMinutes': instance.estimatedMinutes,
      'successCriteria': instance.successCriteria,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_UserLessonProgress _$UserLessonProgressFromJson(Map<String, dynamic> json) =>
    _UserLessonProgress(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      status: json['status'] as String? ?? 'not_started',
      score: (json['score'] as num?)?.toInt(),
      attemptsCount: (json['attempts_count'] as num?)?.toInt() ?? 0,
      bestScore: (json['best_score'] as num?)?.toDouble(),
      totalTimeSpent: (json['total_time_spent'] as num?)?.toInt() ?? 0,
      masteryScore: (json['mastery_score'] as num?)?.toDouble(),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserLessonProgressToJson(_UserLessonProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'lesson_id': instance.lessonId,
      'status': instance.status,
      'score': instance.score,
      'attempts_count': instance.attemptsCount,
      'best_score': instance.bestScore,
      'total_time_spent': instance.totalTimeSpent,
      'mastery_score': instance.masteryScore,
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_PronunciationSession _$PronunciationSessionFromJson(
        Map<String, dynamic> json) =>
    _PronunciationSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String?,
      audioFileUrl: json['audioFileUrl'] as String,
      transcriptExpected: json['transcriptExpected'] as String?,
      transcriptActual: json['transcriptActual'] as String?,
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      accuracyScore: (json['accuracyScore'] as num?)?.toDouble(),
      fluencyScore: (json['fluencyScore'] as num?)?.toDouble(),
      completenessScore: (json['completenessScore'] as num?)?.toDouble(),
      wordLevelScores: json['wordLevelScores'] as Map<String, dynamic>?,
      phonemeAnalysis: json['phonemeAnalysis'] as Map<String, dynamic>?,
      feedbackSummary: json['feedbackSummary'] as String?,
      improvementSuggestions: (json['improvementSuggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sessionDuration: (json['sessionDuration'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PronunciationSessionToJson(
        _PronunciationSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'lessonId': instance.lessonId,
      'audioFileUrl': instance.audioFileUrl,
      'transcriptExpected': instance.transcriptExpected,
      'transcriptActual': instance.transcriptActual,
      'overallScore': instance.overallScore,
      'accuracyScore': instance.accuracyScore,
      'fluencyScore': instance.fluencyScore,
      'completenessScore': instance.completenessScore,
      'wordLevelScores': instance.wordLevelScores,
      'phonemeAnalysis': instance.phonemeAnalysis,
      'feedbackSummary': instance.feedbackSummary,
      'improvementSuggestions': instance.improvementSuggestions,
      'sessionDuration': instance.sessionDuration,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      badgeIconUrl: json['badgeIconUrl'] as String?,
      rarity: json['rarity'] as String? ?? 'common',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 0,
      unlockCriteria: json['unlockCriteria'] as Map<String, dynamic>,
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'badgeIconUrl': instance.badgeIconUrl,
      'rarity': instance.rarity,
      'xpReward': instance.xpReward,
      'unlockCriteria': instance.unlockCriteria,
      'isHidden': instance.isHidden,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_UserAchievement _$UserAchievementFromJson(Map<String, dynamic> json) =>
    _UserAchievement(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      achievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      progressData: json['progressData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserAchievementToJson(_UserAchievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'achievementId': instance.achievementId,
      'unlockedAt': instance.unlockedAt.toIso8601String(),
      'progressData': instance.progressData,
    };

_LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => _LessonModel(
      id: json['id'] as String,
      curriculumId: json['curriculum_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      type: _lessonTypeFromJson(json['type']),
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 30,
      difficulty: _difficultyFromJson(json['difficulty']),
      objectives: json['objectives'] == null
          ? const []
          : _objectivesFromJson(json['objectives']),
      scenario: _scenarioFromJson(json['scenario']),
      keyPhrases: json['key_phrases'] == null
          ? const []
          : _keyPhrasesFromJson(json['key_phrases']),
      dialogues: json['dialogues'] == null
          ? const []
          : _dialoguesFromJson(json['dialogues']),
      grammarPoints: json['grammar_points_json'] == null
          ? const []
          : _grammarPointsFromJson(json['grammar_points_json']),
      pronunciationFocus:
          _pronunciationFocusFromJson(json['pronunciation_focus']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      lastAccessedAt: json['lastAccessedAt'] == null
          ? null
          : DateTime.parse(json['lastAccessedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LessonModelToJson(_LessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'curriculum_id': instance.curriculumId,
      'title': instance.title,
      'description': instance.description,
      'order_index': instance.orderIndex,
      'type': _$LessonTypeEnumMap[instance.type]!,
      'estimated_minutes': instance.estimatedMinutes,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'objectives': instance.objectives,
      'scenario': instance.scenario,
      'key_phrases': instance.keyPhrases,
      'dialogues': instance.dialogues,
      'grammar_points_json': instance.grammarPoints,
      'pronunciation_focus': instance.pronunciationFocus,
      'isCompleted': instance.isCompleted,
      'completionRate': instance.completionRate,
      'lastAccessedAt': instance.lastAccessedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$LessonTypeEnumMap = {
  LessonType.conversation: 'conversation',
  LessonType.pronunciation: 'pronunciation',
  LessonType.vocabulary: 'vocabulary',
  LessonType.grammar: 'grammar',
  LessonType.review: 'review',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.elementary: 'elementary',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
};

_ConversationScenario _$ConversationScenarioFromJson(
        Map<String, dynamic> json) =>
    _ConversationScenario(
      situation: json['situation'] as String,
      location: json['location'] as String,
      aiRole: json['aiRole'] as String,
      userRole: json['userRole'] as String,
      context: json['context'] as String,
      suggestedTopics: (json['suggestedTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalContext: json['additionalContext'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ConversationScenarioToJson(
        _ConversationScenario instance) =>
    <String, dynamic>{
      'situation': instance.situation,
      'location': instance.location,
      'aiRole': instance.aiRole,
      'userRole': instance.userRole,
      'context': instance.context,
      'suggestedTopics': instance.suggestedTopics,
      'additionalContext': instance.additionalContext,
    };

_KeyPhrase _$KeyPhraseFromJson(Map<String, dynamic> json) => _KeyPhrase(
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String,
      usage: json['usage'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pronunciation: json['phonetic'] as String?,
      audioUrl: json['audio_url'] as String?,
    );

Map<String, dynamic> _$KeyPhraseToJson(_KeyPhrase instance) =>
    <String, dynamic>{
      'phrase': instance.phrase,
      'meaning': instance.meaning,
      'usage': instance.usage,
      'examples': instance.examples,
      'phonetic': instance.pronunciation,
      'audio_url': instance.audioUrl,
    };

_GrammarPoint _$GrammarPointFromJson(Map<String, dynamic> json) =>
    _GrammarPoint(
      name: json['name'] as String,
      explanation: json['explanation'] as String,
      structure: json['structure'] as String,
      examples:
          (json['examples'] as List<dynamic>).map((e) => e as String).toList(),
      commonMistakes: (json['commonMistakes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GrammarPointToJson(_GrammarPoint instance) =>
    <String, dynamic>{
      'name': instance.name,
      'explanation': instance.explanation,
      'structure': instance.structure,
      'examples': instance.examples,
      'commonMistakes': instance.commonMistakes,
    };

_PronunciationFocus _$PronunciationFocusFromJson(Map<String, dynamic> json) =>
    _PronunciationFocus(
      targetSounds: (json['targetSounds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      words: (json['words'] as List<dynamic>).map((e) => e as String).toList(),
      sentences:
          (json['sentences'] as List<dynamic>).map((e) => e as String).toList(),
      tips: (json['tips'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PronunciationFocusToJson(_PronunciationFocus instance) =>
    <String, dynamic>{
      'targetSounds': instance.targetSounds,
      'words': instance.words,
      'sentences': instance.sentences,
      'tips': instance.tips,
    };
