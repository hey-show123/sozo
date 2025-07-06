// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Curriculum {
  String get id;
  String get title;
  String? get description;
  String get category;
  @JsonKey(name: 'difficulty_level')
  int get difficultyLevel;
  @JsonKey(name: 'estimated_hours')
  int? get estimatedHours;
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  List<String> get prerequisites;
  @JsonKey(name: 'is_active')
  bool get isActive;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Curriculum
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurriculumCopyWith<Curriculum> get copyWith =>
      _$CurriculumCopyWithImpl<Curriculum>(this as Curriculum, _$identity);

  /// Serializes this Curriculum to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Curriculum &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other.prerequisites, prerequisites) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      difficultyLevel,
      estimatedHours,
      imageUrl,
      const DeepCollectionEquality().hash(prerequisites),
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Curriculum(id: $id, title: $title, description: $description, category: $category, difficultyLevel: $difficultyLevel, estimatedHours: $estimatedHours, imageUrl: $imageUrl, prerequisites: $prerequisites, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CurriculumCopyWith<$Res> {
  factory $CurriculumCopyWith(
          Curriculum value, $Res Function(Curriculum) _then) =
      _$CurriculumCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String category,
      @JsonKey(name: 'difficulty_level') int difficultyLevel,
      @JsonKey(name: 'estimated_hours') int? estimatedHours,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String> prerequisites,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$CurriculumCopyWithImpl<$Res> implements $CurriculumCopyWith<$Res> {
  _$CurriculumCopyWithImpl(this._self, this._then);

  final Curriculum _self;
  final $Res Function(Curriculum) _then;

  /// Create a copy of Curriculum
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? difficultyLevel = null,
    Object? estimatedHours = freezed,
    Object? imageUrl = freezed,
    Object? prerequisites = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyLevel: null == difficultyLevel
          ? _self.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: freezed == estimatedHours
          ? _self.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisites: null == prerequisites
          ? _self.prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Curriculum implements Curriculum {
  const _Curriculum(
      {required this.id,
      required this.title,
      this.description,
      required this.category,
      @JsonKey(name: 'difficulty_level') required this.difficultyLevel,
      @JsonKey(name: 'estimated_hours') this.estimatedHours,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<String> prerequisites = const [],
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _prerequisites = prerequisites;
  factory _Curriculum.fromJson(Map<String, dynamic> json) =>
      _$CurriculumFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String category;
  @override
  @JsonKey(name: 'difficulty_level')
  final int difficultyLevel;
  @override
  @JsonKey(name: 'estimated_hours')
  final int? estimatedHours;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String> _prerequisites;
  @override
  @JsonKey()
  List<String> get prerequisites {
    if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prerequisites);
  }

  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of Curriculum
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurriculumCopyWith<_Curriculum> get copyWith =>
      __$CurriculumCopyWithImpl<_Curriculum>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CurriculumToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Curriculum &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._prerequisites, _prerequisites) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      difficultyLevel,
      estimatedHours,
      imageUrl,
      const DeepCollectionEquality().hash(_prerequisites),
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Curriculum(id: $id, title: $title, description: $description, category: $category, difficultyLevel: $difficultyLevel, estimatedHours: $estimatedHours, imageUrl: $imageUrl, prerequisites: $prerequisites, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CurriculumCopyWith<$Res>
    implements $CurriculumCopyWith<$Res> {
  factory _$CurriculumCopyWith(
          _Curriculum value, $Res Function(_Curriculum) _then) =
      __$CurriculumCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String category,
      @JsonKey(name: 'difficulty_level') int difficultyLevel,
      @JsonKey(name: 'estimated_hours') int? estimatedHours,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<String> prerequisites,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$CurriculumCopyWithImpl<$Res> implements _$CurriculumCopyWith<$Res> {
  __$CurriculumCopyWithImpl(this._self, this._then);

  final _Curriculum _self;
  final $Res Function(_Curriculum) _then;

  /// Create a copy of Curriculum
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? difficultyLevel = null,
    Object? estimatedHours = freezed,
    Object? imageUrl = freezed,
    Object? prerequisites = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Curriculum(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyLevel: null == difficultyLevel
          ? _self.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: freezed == estimatedHours
          ? _self.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      prerequisites: null == prerequisites
          ? _self._prerequisites
          : prerequisites // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$Lesson {
  String get id;
  String? get curriculumId;
  String get title;
  String? get description;
  int get orderIndex;
  String get lessonType;
  double? get difficultyScore;
  int get estimatedMinutes;
  List<KeyPhrase> get keyPhrases;
  List<Dialogue> get dialogues;
  List<String> get grammarPoints;
  String? get culturalNotes;
  bool get isActive;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LessonCopyWith<Lesson> get copyWith =>
      _$LessonCopyWithImpl<Lesson>(this as Lesson, _$identity);

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Lesson &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.curriculumId, curriculumId) ||
                other.curriculumId == curriculumId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.difficultyScore, difficultyScore) ||
                other.difficultyScore == difficultyScore) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality()
                .equals(other.keyPhrases, keyPhrases) &&
            const DeepCollectionEquality().equals(other.dialogues, dialogues) &&
            const DeepCollectionEquality()
                .equals(other.grammarPoints, grammarPoints) &&
            (identical(other.culturalNotes, culturalNotes) ||
                other.culturalNotes == culturalNotes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      curriculumId,
      title,
      description,
      orderIndex,
      lessonType,
      difficultyScore,
      estimatedMinutes,
      const DeepCollectionEquality().hash(keyPhrases),
      const DeepCollectionEquality().hash(dialogues),
      const DeepCollectionEquality().hash(grammarPoints),
      culturalNotes,
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Lesson(id: $id, curriculumId: $curriculumId, title: $title, description: $description, orderIndex: $orderIndex, lessonType: $lessonType, difficultyScore: $difficultyScore, estimatedMinutes: $estimatedMinutes, keyPhrases: $keyPhrases, dialogues: $dialogues, grammarPoints: $grammarPoints, culturalNotes: $culturalNotes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) _then) =
      _$LessonCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? curriculumId,
      String title,
      String? description,
      int orderIndex,
      String lessonType,
      double? difficultyScore,
      int estimatedMinutes,
      List<KeyPhrase> keyPhrases,
      List<Dialogue> dialogues,
      List<String> grammarPoints,
      String? culturalNotes,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LessonCopyWithImpl<$Res> implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._self, this._then);

  final Lesson _self;
  final $Res Function(Lesson) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? curriculumId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? orderIndex = null,
    Object? lessonType = null,
    Object? difficultyScore = freezed,
    Object? estimatedMinutes = null,
    Object? keyPhrases = null,
    Object? dialogues = null,
    Object? grammarPoints = null,
    Object? culturalNotes = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      curriculumId: freezed == curriculumId
          ? _self.curriculumId
          : curriculumId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      lessonType: null == lessonType
          ? _self.lessonType
          : lessonType // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyScore: freezed == difficultyScore
          ? _self.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      keyPhrases: null == keyPhrases
          ? _self.keyPhrases
          : keyPhrases // ignore: cast_nullable_to_non_nullable
              as List<KeyPhrase>,
      dialogues: null == dialogues
          ? _self.dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as List<Dialogue>,
      grammarPoints: null == grammarPoints
          ? _self.grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      culturalNotes: freezed == culturalNotes
          ? _self.culturalNotes
          : culturalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Lesson implements Lesson {
  const _Lesson(
      {required this.id,
      this.curriculumId,
      required this.title,
      this.description,
      required this.orderIndex,
      required this.lessonType,
      this.difficultyScore,
      this.estimatedMinutes = 30,
      final List<KeyPhrase> keyPhrases = const [],
      final List<Dialogue> dialogues = const [],
      final List<String> grammarPoints = const [],
      this.culturalNotes,
      this.isActive = true,
      this.createdAt,
      this.updatedAt})
      : _keyPhrases = keyPhrases,
        _dialogues = dialogues,
        _grammarPoints = grammarPoints;
  factory _Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  @override
  final String id;
  @override
  final String? curriculumId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final int orderIndex;
  @override
  final String lessonType;
  @override
  final double? difficultyScore;
  @override
  @JsonKey()
  final int estimatedMinutes;
  final List<KeyPhrase> _keyPhrases;
  @override
  @JsonKey()
  List<KeyPhrase> get keyPhrases {
    if (_keyPhrases is EqualUnmodifiableListView) return _keyPhrases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyPhrases);
  }

  final List<Dialogue> _dialogues;
  @override
  @JsonKey()
  List<Dialogue> get dialogues {
    if (_dialogues is EqualUnmodifiableListView) return _dialogues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dialogues);
  }

  final List<String> _grammarPoints;
  @override
  @JsonKey()
  List<String> get grammarPoints {
    if (_grammarPoints is EqualUnmodifiableListView) return _grammarPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_grammarPoints);
  }

  @override
  final String? culturalNotes;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LessonCopyWith<_Lesson> get copyWith =>
      __$LessonCopyWithImpl<_Lesson>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LessonToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Lesson &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.curriculumId, curriculumId) ||
                other.curriculumId == curriculumId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.difficultyScore, difficultyScore) ||
                other.difficultyScore == difficultyScore) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality()
                .equals(other._keyPhrases, _keyPhrases) &&
            const DeepCollectionEquality()
                .equals(other._dialogues, _dialogues) &&
            const DeepCollectionEquality()
                .equals(other._grammarPoints, _grammarPoints) &&
            (identical(other.culturalNotes, culturalNotes) ||
                other.culturalNotes == culturalNotes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      curriculumId,
      title,
      description,
      orderIndex,
      lessonType,
      difficultyScore,
      estimatedMinutes,
      const DeepCollectionEquality().hash(_keyPhrases),
      const DeepCollectionEquality().hash(_dialogues),
      const DeepCollectionEquality().hash(_grammarPoints),
      culturalNotes,
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Lesson(id: $id, curriculumId: $curriculumId, title: $title, description: $description, orderIndex: $orderIndex, lessonType: $lessonType, difficultyScore: $difficultyScore, estimatedMinutes: $estimatedMinutes, keyPhrases: $keyPhrases, dialogues: $dialogues, grammarPoints: $grammarPoints, culturalNotes: $culturalNotes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$LessonCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$LessonCopyWith(_Lesson value, $Res Function(_Lesson) _then) =
      __$LessonCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? curriculumId,
      String title,
      String? description,
      int orderIndex,
      String lessonType,
      double? difficultyScore,
      int estimatedMinutes,
      List<KeyPhrase> keyPhrases,
      List<Dialogue> dialogues,
      List<String> grammarPoints,
      String? culturalNotes,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$LessonCopyWithImpl<$Res> implements _$LessonCopyWith<$Res> {
  __$LessonCopyWithImpl(this._self, this._then);

  final _Lesson _self;
  final $Res Function(_Lesson) _then;

  /// Create a copy of Lesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? curriculumId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? orderIndex = null,
    Object? lessonType = null,
    Object? difficultyScore = freezed,
    Object? estimatedMinutes = null,
    Object? keyPhrases = null,
    Object? dialogues = null,
    Object? grammarPoints = null,
    Object? culturalNotes = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Lesson(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      curriculumId: freezed == curriculumId
          ? _self.curriculumId
          : curriculumId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      lessonType: null == lessonType
          ? _self.lessonType
          : lessonType // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyScore: freezed == difficultyScore
          ? _self.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      keyPhrases: null == keyPhrases
          ? _self._keyPhrases
          : keyPhrases // ignore: cast_nullable_to_non_nullable
              as List<KeyPhrase>,
      dialogues: null == dialogues
          ? _self._dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as List<Dialogue>,
      grammarPoints: null == grammarPoints
          ? _self._grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      culturalNotes: freezed == culturalNotes
          ? _self.culturalNotes
          : culturalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$KeyPhrase {
  String get phrase;
  String? get phonetic;
  String get meaning;
  String? get usage;
  List<String> get examples;
  String? get audioUrl;

  /// Create a copy of KeyPhrase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KeyPhraseCopyWith<KeyPhrase> get copyWith =>
      _$KeyPhraseCopyWithImpl<KeyPhrase>(this as KeyPhrase, _$identity);

  /// Serializes this KeyPhrase to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KeyPhrase &&
            (identical(other.phrase, phrase) || other.phrase == phrase) &&
            (identical(other.phonetic, phonetic) ||
                other.phonetic == phonetic) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            const DeepCollectionEquality().equals(other.examples, examples) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phrase, phonetic, meaning, usage,
      const DeepCollectionEquality().hash(examples), audioUrl);

  @override
  String toString() {
    return 'KeyPhrase(phrase: $phrase, phonetic: $phonetic, meaning: $meaning, usage: $usage, examples: $examples, audioUrl: $audioUrl)';
  }
}

/// @nodoc
abstract mixin class $KeyPhraseCopyWith<$Res> {
  factory $KeyPhraseCopyWith(KeyPhrase value, $Res Function(KeyPhrase) _then) =
      _$KeyPhraseCopyWithImpl;
  @useResult
  $Res call(
      {String phrase,
      String? phonetic,
      String meaning,
      String? usage,
      List<String> examples,
      String? audioUrl});
}

/// @nodoc
class _$KeyPhraseCopyWithImpl<$Res> implements $KeyPhraseCopyWith<$Res> {
  _$KeyPhraseCopyWithImpl(this._self, this._then);

  final KeyPhrase _self;
  final $Res Function(KeyPhrase) _then;

  /// Create a copy of KeyPhrase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phrase = null,
    Object? phonetic = freezed,
    Object? meaning = null,
    Object? usage = freezed,
    Object? examples = null,
    Object? audioUrl = freezed,
  }) {
    return _then(_self.copyWith(
      phrase: null == phrase
          ? _self.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as String,
      phonetic: freezed == phonetic
          ? _self.phonetic
          : phonetic // ignore: cast_nullable_to_non_nullable
              as String?,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      usage: freezed == usage
          ? _self.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: null == examples
          ? _self.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _KeyPhrase implements KeyPhrase {
  const _KeyPhrase(
      {required this.phrase,
      this.phonetic,
      required this.meaning,
      this.usage,
      final List<String> examples = const [],
      this.audioUrl})
      : _examples = examples;
  factory _KeyPhrase.fromJson(Map<String, dynamic> json) =>
      _$KeyPhraseFromJson(json);

  @override
  final String phrase;
  @override
  final String? phonetic;
  @override
  final String meaning;
  @override
  final String? usage;
  final List<String> _examples;
  @override
  @JsonKey()
  List<String> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  @override
  final String? audioUrl;

  /// Create a copy of KeyPhrase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KeyPhraseCopyWith<_KeyPhrase> get copyWith =>
      __$KeyPhraseCopyWithImpl<_KeyPhrase>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KeyPhraseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KeyPhrase &&
            (identical(other.phrase, phrase) || other.phrase == phrase) &&
            (identical(other.phonetic, phonetic) ||
                other.phonetic == phonetic) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.usage, usage) || other.usage == usage) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, phrase, phonetic, meaning, usage,
      const DeepCollectionEquality().hash(_examples), audioUrl);

  @override
  String toString() {
    return 'KeyPhrase(phrase: $phrase, phonetic: $phonetic, meaning: $meaning, usage: $usage, examples: $examples, audioUrl: $audioUrl)';
  }
}

/// @nodoc
abstract mixin class _$KeyPhraseCopyWith<$Res>
    implements $KeyPhraseCopyWith<$Res> {
  factory _$KeyPhraseCopyWith(
          _KeyPhrase value, $Res Function(_KeyPhrase) _then) =
      __$KeyPhraseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String phrase,
      String? phonetic,
      String meaning,
      String? usage,
      List<String> examples,
      String? audioUrl});
}

/// @nodoc
class __$KeyPhraseCopyWithImpl<$Res> implements _$KeyPhraseCopyWith<$Res> {
  __$KeyPhraseCopyWithImpl(this._self, this._then);

  final _KeyPhrase _self;
  final $Res Function(_KeyPhrase) _then;

  /// Create a copy of KeyPhrase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? phrase = null,
    Object? phonetic = freezed,
    Object? meaning = null,
    Object? usage = freezed,
    Object? examples = null,
    Object? audioUrl = freezed,
  }) {
    return _then(_KeyPhrase(
      phrase: null == phrase
          ? _self.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as String,
      phonetic: freezed == phonetic
          ? _self.phonetic
          : phonetic // ignore: cast_nullable_to_non_nullable
              as String?,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      usage: freezed == usage
          ? _self.usage
          : usage // ignore: cast_nullable_to_non_nullable
              as String?,
      examples: null == examples
          ? _self._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Dialogue {
  String get speaker;
  String get text;
  String? get audio;
  String? get translation;

  /// Create a copy of Dialogue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DialogueCopyWith<Dialogue> get copyWith =>
      _$DialogueCopyWithImpl<Dialogue>(this as Dialogue, _$identity);

  /// Serializes this Dialogue to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Dialogue &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.translation, translation) ||
                other.translation == translation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, speaker, text, audio, translation);

  @override
  String toString() {
    return 'Dialogue(speaker: $speaker, text: $text, audio: $audio, translation: $translation)';
  }
}

/// @nodoc
abstract mixin class $DialogueCopyWith<$Res> {
  factory $DialogueCopyWith(Dialogue value, $Res Function(Dialogue) _then) =
      _$DialogueCopyWithImpl;
  @useResult
  $Res call({String speaker, String text, String? audio, String? translation});
}

/// @nodoc
class _$DialogueCopyWithImpl<$Res> implements $DialogueCopyWith<$Res> {
  _$DialogueCopyWithImpl(this._self, this._then);

  final Dialogue _self;
  final $Res Function(Dialogue) _then;

  /// Create a copy of Dialogue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speaker = null,
    Object? text = null,
    Object? audio = freezed,
    Object? translation = freezed,
  }) {
    return _then(_self.copyWith(
      speaker: null == speaker
          ? _self.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audio: freezed == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: freezed == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Dialogue implements Dialogue {
  const _Dialogue(
      {required this.speaker,
      required this.text,
      this.audio,
      this.translation});
  factory _Dialogue.fromJson(Map<String, dynamic> json) =>
      _$DialogueFromJson(json);

  @override
  final String speaker;
  @override
  final String text;
  @override
  final String? audio;
  @override
  final String? translation;

  /// Create a copy of Dialogue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DialogueCopyWith<_Dialogue> get copyWith =>
      __$DialogueCopyWithImpl<_Dialogue>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DialogueToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Dialogue &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.translation, translation) ||
                other.translation == translation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, speaker, text, audio, translation);

  @override
  String toString() {
    return 'Dialogue(speaker: $speaker, text: $text, audio: $audio, translation: $translation)';
  }
}

/// @nodoc
abstract mixin class _$DialogueCopyWith<$Res>
    implements $DialogueCopyWith<$Res> {
  factory _$DialogueCopyWith(_Dialogue value, $Res Function(_Dialogue) _then) =
      __$DialogueCopyWithImpl;
  @override
  @useResult
  $Res call({String speaker, String text, String? audio, String? translation});
}

/// @nodoc
class __$DialogueCopyWithImpl<$Res> implements _$DialogueCopyWith<$Res> {
  __$DialogueCopyWithImpl(this._self, this._then);

  final _Dialogue _self;
  final $Res Function(_Dialogue) _then;

  /// Create a copy of Dialogue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? speaker = null,
    Object? text = null,
    Object? audio = freezed,
    Object? translation = freezed,
  }) {
    return _then(_Dialogue(
      speaker: null == speaker
          ? _self.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      audio: freezed == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: freezed == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
