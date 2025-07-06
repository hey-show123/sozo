// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Course {
  String get id;
  String get title;
  String get description;
  int get difficultyLevel;
  String get category;
  String? get imageUrl;
  int? get estimatedHours;
  List<String> get prerequisites;
  bool get isActive;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CourseCopyWith<Course> get copyWith =>
      _$CourseCopyWithImpl<Course>(this as Course, _$identity);

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Course &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
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
      difficultyLevel,
      category,
      imageUrl,
      estimatedHours,
      const DeepCollectionEquality().hash(prerequisites),
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Course(id: $id, title: $title, description: $description, difficultyLevel: $difficultyLevel, category: $category, imageUrl: $imageUrl, estimatedHours: $estimatedHours, prerequisites: $prerequisites, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) _then) =
      _$CourseCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int difficultyLevel,
      String category,
      String? imageUrl,
      int? estimatedHours,
      List<String> prerequisites,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$CourseCopyWithImpl<$Res> implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._self, this._then);

  final Course _self;
  final $Res Function(Course) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? difficultyLevel = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? estimatedHours = freezed,
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
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyLevel: null == difficultyLevel
          ? _self.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedHours: freezed == estimatedHours
          ? _self.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _Course implements Course {
  const _Course(
      {required this.id,
      required this.title,
      required this.description,
      required this.difficultyLevel,
      required this.category,
      this.imageUrl,
      this.estimatedHours,
      final List<String> prerequisites = const [],
      this.isActive = true,
      this.createdAt,
      this.updatedAt})
      : _prerequisites = prerequisites;
  factory _Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int difficultyLevel;
  @override
  final String category;
  @override
  final String? imageUrl;
  @override
  final int? estimatedHours;
  final List<String> _prerequisites;
  @override
  @JsonKey()
  List<String> get prerequisites {
    if (_prerequisites is EqualUnmodifiableListView) return _prerequisites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prerequisites);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CourseCopyWith<_Course> get copyWith =>
      __$CourseCopyWithImpl<_Course>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CourseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Course &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
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
      difficultyLevel,
      category,
      imageUrl,
      estimatedHours,
      const DeepCollectionEquality().hash(_prerequisites),
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Course(id: $id, title: $title, description: $description, difficultyLevel: $difficultyLevel, category: $category, imageUrl: $imageUrl, estimatedHours: $estimatedHours, prerequisites: $prerequisites, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CourseCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$CourseCopyWith(_Course value, $Res Function(_Course) _then) =
      __$CourseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int difficultyLevel,
      String category,
      String? imageUrl,
      int? estimatedHours,
      List<String> prerequisites,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$CourseCopyWithImpl<$Res> implements _$CourseCopyWith<$Res> {
  __$CourseCopyWithImpl(this._self, this._then);

  final _Course _self;
  final $Res Function(_Course) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? difficultyLevel = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? estimatedHours = freezed,
    Object? prerequisites = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Course(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyLevel: null == difficultyLevel
          ? _self.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedHours: freezed == estimatedHours
          ? _self.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int?,
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
mixin _$Module {
  String get id;
  String get courseId;
  String get title;
  String? get description;
  int get orderIndex;
  Map<String, dynamic> get unlockRequirements;
  int? get estimatedMinutes;
  bool get isActive;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Module
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ModuleCopyWith<Module> get copyWith =>
      _$ModuleCopyWithImpl<Module>(this as Module, _$identity);

  /// Serializes this Module to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Module &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality()
                .equals(other.unlockRequirements, unlockRequirements) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
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
      courseId,
      title,
      description,
      orderIndex,
      const DeepCollectionEquality().hash(unlockRequirements),
      estimatedMinutes,
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Module(id: $id, courseId: $courseId, title: $title, description: $description, orderIndex: $orderIndex, unlockRequirements: $unlockRequirements, estimatedMinutes: $estimatedMinutes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $ModuleCopyWith<$Res> {
  factory $ModuleCopyWith(Module value, $Res Function(Module) _then) =
      _$ModuleCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String courseId,
      String title,
      String? description,
      int orderIndex,
      Map<String, dynamic> unlockRequirements,
      int? estimatedMinutes,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ModuleCopyWithImpl<$Res> implements $ModuleCopyWith<$Res> {
  _$ModuleCopyWithImpl(this._self, this._then);

  final Module _self;
  final $Res Function(Module) _then;

  /// Create a copy of Module
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? orderIndex = null,
    Object? unlockRequirements = null,
    Object? estimatedMinutes = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _self.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
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
      unlockRequirements: null == unlockRequirements
          ? _self.unlockRequirements
          : unlockRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      estimatedMinutes: freezed == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
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
class _Module implements Module {
  const _Module(
      {required this.id,
      required this.courseId,
      required this.title,
      this.description,
      required this.orderIndex,
      final Map<String, dynamic> unlockRequirements = const {},
      this.estimatedMinutes,
      this.isActive = true,
      this.createdAt,
      this.updatedAt})
      : _unlockRequirements = unlockRequirements;
  factory _Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);

  @override
  final String id;
  @override
  final String courseId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final int orderIndex;
  final Map<String, dynamic> _unlockRequirements;
  @override
  @JsonKey()
  Map<String, dynamic> get unlockRequirements {
    if (_unlockRequirements is EqualUnmodifiableMapView)
      return _unlockRequirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_unlockRequirements);
  }

  @override
  final int? estimatedMinutes;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Module
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ModuleCopyWith<_Module> get copyWith =>
      __$ModuleCopyWithImpl<_Module>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ModuleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Module &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality()
                .equals(other._unlockRequirements, _unlockRequirements) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
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
      courseId,
      title,
      description,
      orderIndex,
      const DeepCollectionEquality().hash(_unlockRequirements),
      estimatedMinutes,
      isActive,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Module(id: $id, courseId: $courseId, title: $title, description: $description, orderIndex: $orderIndex, unlockRequirements: $unlockRequirements, estimatedMinutes: $estimatedMinutes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$ModuleCopyWith<$Res> implements $ModuleCopyWith<$Res> {
  factory _$ModuleCopyWith(_Module value, $Res Function(_Module) _then) =
      __$ModuleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String courseId,
      String title,
      String? description,
      int orderIndex,
      Map<String, dynamic> unlockRequirements,
      int? estimatedMinutes,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$ModuleCopyWithImpl<$Res> implements _$ModuleCopyWith<$Res> {
  __$ModuleCopyWithImpl(this._self, this._then);

  final _Module _self;
  final $Res Function(_Module) _then;

  /// Create a copy of Module
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? description = freezed,
    Object? orderIndex = null,
    Object? unlockRequirements = null,
    Object? estimatedMinutes = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Module(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _self.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
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
      unlockRequirements: null == unlockRequirements
          ? _self._unlockRequirements
          : unlockRequirements // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      estimatedMinutes: freezed == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
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
  String? get moduleId;
  String get title;
  String? get description;
  int get level;
  int? get order;
  String? get lessonType;
  double? get difficultyScore;
  List<String> get targetPhrases;
  List<String> get grammarPoints;
  String? get culturalNotes;
  DateTime? get createdAt;

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
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.difficultyScore, difficultyScore) ||
                other.difficultyScore == difficultyScore) &&
            const DeepCollectionEquality()
                .equals(other.targetPhrases, targetPhrases) &&
            const DeepCollectionEquality()
                .equals(other.grammarPoints, grammarPoints) &&
            (identical(other.culturalNotes, culturalNotes) ||
                other.culturalNotes == culturalNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      moduleId,
      title,
      description,
      level,
      order,
      lessonType,
      difficultyScore,
      const DeepCollectionEquality().hash(targetPhrases),
      const DeepCollectionEquality().hash(grammarPoints),
      culturalNotes,
      createdAt);

  @override
  String toString() {
    return 'Lesson(id: $id, moduleId: $moduleId, title: $title, description: $description, level: $level, order: $order, lessonType: $lessonType, difficultyScore: $difficultyScore, targetPhrases: $targetPhrases, grammarPoints: $grammarPoints, culturalNotes: $culturalNotes, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) _then) =
      _$LessonCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? moduleId,
      String title,
      String? description,
      int level,
      int? order,
      String? lessonType,
      double? difficultyScore,
      List<String> targetPhrases,
      List<String> grammarPoints,
      String? culturalNotes,
      DateTime? createdAt});
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
    Object? moduleId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? level = null,
    Object? order = freezed,
    Object? lessonType = freezed,
    Object? difficultyScore = freezed,
    Object? targetPhrases = null,
    Object? grammarPoints = null,
    Object? culturalNotes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: freezed == moduleId
          ? _self.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      order: freezed == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      lessonType: freezed == lessonType
          ? _self.lessonType
          : lessonType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyScore: freezed == difficultyScore
          ? _self.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      targetPhrases: null == targetPhrases
          ? _self.targetPhrases
          : targetPhrases // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grammarPoints: null == grammarPoints
          ? _self.grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      culturalNotes: freezed == culturalNotes
          ? _self.culturalNotes
          : culturalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Lesson implements Lesson {
  const _Lesson(
      {required this.id,
      this.moduleId,
      required this.title,
      this.description,
      required this.level,
      this.order,
      this.lessonType,
      this.difficultyScore,
      final List<String> targetPhrases = const [],
      final List<String> grammarPoints = const [],
      this.culturalNotes,
      this.createdAt})
      : _targetPhrases = targetPhrases,
        _grammarPoints = grammarPoints;
  factory _Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  @override
  final String id;
  @override
  final String? moduleId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final int level;
  @override
  final int? order;
  @override
  final String? lessonType;
  @override
  final double? difficultyScore;
  final List<String> _targetPhrases;
  @override
  @JsonKey()
  List<String> get targetPhrases {
    if (_targetPhrases is EqualUnmodifiableListView) return _targetPhrases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetPhrases);
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
  final DateTime? createdAt;

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
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.lessonType, lessonType) ||
                other.lessonType == lessonType) &&
            (identical(other.difficultyScore, difficultyScore) ||
                other.difficultyScore == difficultyScore) &&
            const DeepCollectionEquality()
                .equals(other._targetPhrases, _targetPhrases) &&
            const DeepCollectionEquality()
                .equals(other._grammarPoints, _grammarPoints) &&
            (identical(other.culturalNotes, culturalNotes) ||
                other.culturalNotes == culturalNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      moduleId,
      title,
      description,
      level,
      order,
      lessonType,
      difficultyScore,
      const DeepCollectionEquality().hash(_targetPhrases),
      const DeepCollectionEquality().hash(_grammarPoints),
      culturalNotes,
      createdAt);

  @override
  String toString() {
    return 'Lesson(id: $id, moduleId: $moduleId, title: $title, description: $description, level: $level, order: $order, lessonType: $lessonType, difficultyScore: $difficultyScore, targetPhrases: $targetPhrases, grammarPoints: $grammarPoints, culturalNotes: $culturalNotes, createdAt: $createdAt)';
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
      String? moduleId,
      String title,
      String? description,
      int level,
      int? order,
      String? lessonType,
      double? difficultyScore,
      List<String> targetPhrases,
      List<String> grammarPoints,
      String? culturalNotes,
      DateTime? createdAt});
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
    Object? moduleId = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? level = null,
    Object? order = freezed,
    Object? lessonType = freezed,
    Object? difficultyScore = freezed,
    Object? targetPhrases = null,
    Object? grammarPoints = null,
    Object? culturalNotes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_Lesson(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: freezed == moduleId
          ? _self.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      order: freezed == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      lessonType: freezed == lessonType
          ? _self.lessonType
          : lessonType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyScore: freezed == difficultyScore
          ? _self.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      targetPhrases: null == targetPhrases
          ? _self._targetPhrases
          : targetPhrases // ignore: cast_nullable_to_non_nullable
              as List<String>,
      grammarPoints: null == grammarPoints
          ? _self._grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      culturalNotes: freezed == culturalNotes
          ? _self.culturalNotes
          : culturalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$LessonActivity {
  String get id;
  String get lessonId;
  String get activityType;
  int get orderIndex;
  Map<String, dynamic> get content;
  String? get audioUrl;
  int? get estimatedMinutes;
  Map<String, dynamic> get successCriteria;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of LessonActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LessonActivityCopyWith<LessonActivity> get copyWith =>
      _$LessonActivityCopyWithImpl<LessonActivity>(
          this as LessonActivity, _$identity);

  /// Serializes this LessonActivity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LessonActivity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality().equals(other.content, content) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality()
                .equals(other.successCriteria, successCriteria) &&
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
      lessonId,
      activityType,
      orderIndex,
      const DeepCollectionEquality().hash(content),
      audioUrl,
      estimatedMinutes,
      const DeepCollectionEquality().hash(successCriteria),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'LessonActivity(id: $id, lessonId: $lessonId, activityType: $activityType, orderIndex: $orderIndex, content: $content, audioUrl: $audioUrl, estimatedMinutes: $estimatedMinutes, successCriteria: $successCriteria, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $LessonActivityCopyWith<$Res> {
  factory $LessonActivityCopyWith(
          LessonActivity value, $Res Function(LessonActivity) _then) =
      _$LessonActivityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String activityType,
      int orderIndex,
      Map<String, dynamic> content,
      String? audioUrl,
      int? estimatedMinutes,
      Map<String, dynamic> successCriteria,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$LessonActivityCopyWithImpl<$Res>
    implements $LessonActivityCopyWith<$Res> {
  _$LessonActivityCopyWithImpl(this._self, this._then);

  final LessonActivity _self;
  final $Res Function(LessonActivity) _then;

  /// Create a copy of LessonActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? activityType = null,
    Object? orderIndex = null,
    Object? content = null,
    Object? audioUrl = freezed,
    Object? estimatedMinutes = freezed,
    Object? successCriteria = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _self.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedMinutes: freezed == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      successCriteria: null == successCriteria
          ? _self.successCriteria
          : successCriteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
class _LessonActivity implements LessonActivity {
  const _LessonActivity(
      {required this.id,
      required this.lessonId,
      required this.activityType,
      required this.orderIndex,
      required final Map<String, dynamic> content,
      this.audioUrl,
      this.estimatedMinutes,
      final Map<String, dynamic> successCriteria = const {},
      this.createdAt,
      this.updatedAt})
      : _content = content,
        _successCriteria = successCriteria;
  factory _LessonActivity.fromJson(Map<String, dynamic> json) =>
      _$LessonActivityFromJson(json);

  @override
  final String id;
  @override
  final String lessonId;
  @override
  final String activityType;
  @override
  final int orderIndex;
  final Map<String, dynamic> _content;
  @override
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  @override
  final String? audioUrl;
  @override
  final int? estimatedMinutes;
  final Map<String, dynamic> _successCriteria;
  @override
  @JsonKey()
  Map<String, dynamic> get successCriteria {
    if (_successCriteria is EqualUnmodifiableMapView) return _successCriteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_successCriteria);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of LessonActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LessonActivityCopyWith<_LessonActivity> get copyWith =>
      __$LessonActivityCopyWithImpl<_LessonActivity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LessonActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LessonActivity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality()
                .equals(other._successCriteria, _successCriteria) &&
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
      lessonId,
      activityType,
      orderIndex,
      const DeepCollectionEquality().hash(_content),
      audioUrl,
      estimatedMinutes,
      const DeepCollectionEquality().hash(_successCriteria),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'LessonActivity(id: $id, lessonId: $lessonId, activityType: $activityType, orderIndex: $orderIndex, content: $content, audioUrl: $audioUrl, estimatedMinutes: $estimatedMinutes, successCriteria: $successCriteria, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$LessonActivityCopyWith<$Res>
    implements $LessonActivityCopyWith<$Res> {
  factory _$LessonActivityCopyWith(
          _LessonActivity value, $Res Function(_LessonActivity) _then) =
      __$LessonActivityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String lessonId,
      String activityType,
      int orderIndex,
      Map<String, dynamic> content,
      String? audioUrl,
      int? estimatedMinutes,
      Map<String, dynamic> successCriteria,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$LessonActivityCopyWithImpl<$Res>
    implements _$LessonActivityCopyWith<$Res> {
  __$LessonActivityCopyWithImpl(this._self, this._then);

  final _LessonActivity _self;
  final $Res Function(_LessonActivity) _then;

  /// Create a copy of LessonActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? activityType = null,
    Object? orderIndex = null,
    Object? content = null,
    Object? audioUrl = freezed,
    Object? estimatedMinutes = freezed,
    Object? successCriteria = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_LessonActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _self.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _self._content
          : content // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedMinutes: freezed == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      successCriteria: null == successCriteria
          ? _self._successCriteria
          : successCriteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
mixin _$UserLessonProgress {
  String? get id;
  @JsonKey(name: 'user_id')
  String get userId;
  @JsonKey(name: 'lesson_id')
  String get lessonId;
  String get status;
  int? get score;
  @JsonKey(name: 'attempts_count')
  int get attemptsCount;
  @JsonKey(name: 'best_score')
  double? get bestScore;
  @JsonKey(name: 'total_time_spent')
  int get totalTimeSpent;
  @JsonKey(name: 'mastery_score')
  double? get masteryScore;
  @JsonKey(name: 'mastery_level')
  int get masteryLevel;
  @JsonKey(name: 'last_attempt_at')
  DateTime? get lastAttemptAt;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of UserLessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserLessonProgressCopyWith<UserLessonProgress> get copyWith =>
      _$UserLessonProgressCopyWithImpl<UserLessonProgress>(
          this as UserLessonProgress, _$identity);

  /// Serializes this UserLessonProgress to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserLessonProgress &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.attemptsCount, attemptsCount) ||
                other.attemptsCount == attemptsCount) &&
            (identical(other.bestScore, bestScore) ||
                other.bestScore == bestScore) &&
            (identical(other.totalTimeSpent, totalTimeSpent) ||
                other.totalTimeSpent == totalTimeSpent) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            (identical(other.lastAttemptAt, lastAttemptAt) ||
                other.lastAttemptAt == lastAttemptAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
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
      userId,
      lessonId,
      status,
      score,
      attemptsCount,
      bestScore,
      totalTimeSpent,
      masteryScore,
      masteryLevel,
      lastAttemptAt,
      completedAt,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'UserLessonProgress(id: $id, userId: $userId, lessonId: $lessonId, status: $status, score: $score, attemptsCount: $attemptsCount, bestScore: $bestScore, totalTimeSpent: $totalTimeSpent, masteryScore: $masteryScore, masteryLevel: $masteryLevel, lastAttemptAt: $lastAttemptAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $UserLessonProgressCopyWith<$Res> {
  factory $UserLessonProgressCopyWith(
          UserLessonProgress value, $Res Function(UserLessonProgress) _then) =
      _$UserLessonProgressCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'lesson_id') String lessonId,
      String status,
      int? score,
      @JsonKey(name: 'attempts_count') int attemptsCount,
      @JsonKey(name: 'best_score') double? bestScore,
      @JsonKey(name: 'total_time_spent') int totalTimeSpent,
      @JsonKey(name: 'mastery_score') double? masteryScore,
      @JsonKey(name: 'mastery_level') int masteryLevel,
      @JsonKey(name: 'last_attempt_at') DateTime? lastAttemptAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$UserLessonProgressCopyWithImpl<$Res>
    implements $UserLessonProgressCopyWith<$Res> {
  _$UserLessonProgressCopyWithImpl(this._self, this._then);

  final UserLessonProgress _self;
  final $Res Function(UserLessonProgress) _then;

  /// Create a copy of UserLessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? lessonId = null,
    Object? status = null,
    Object? score = freezed,
    Object? attemptsCount = null,
    Object? bestScore = freezed,
    Object? totalTimeSpent = null,
    Object? masteryScore = freezed,
    Object? masteryLevel = null,
    Object? lastAttemptAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      score: freezed == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      attemptsCount: null == attemptsCount
          ? _self.attemptsCount
          : attemptsCount // ignore: cast_nullable_to_non_nullable
              as int,
      bestScore: freezed == bestScore
          ? _self.bestScore
          : bestScore // ignore: cast_nullable_to_non_nullable
              as double?,
      totalTimeSpent: null == totalTimeSpent
          ? _self.totalTimeSpent
          : totalTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      masteryScore: freezed == masteryScore
          ? _self.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double?,
      masteryLevel: null == masteryLevel
          ? _self.masteryLevel
          : masteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      lastAttemptAt: freezed == lastAttemptAt
          ? _self.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
class _UserLessonProgress implements UserLessonProgress {
  const _UserLessonProgress(
      {this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'lesson_id') required this.lessonId,
      this.status = 'not_started',
      this.score,
      @JsonKey(name: 'attempts_count') this.attemptsCount = 0,
      @JsonKey(name: 'best_score') this.bestScore,
      @JsonKey(name: 'total_time_spent') this.totalTimeSpent = 0,
      @JsonKey(name: 'mastery_score') this.masteryScore,
      @JsonKey(name: 'mastery_level') this.masteryLevel = 0,
      @JsonKey(name: 'last_attempt_at') this.lastAttemptAt,
      @JsonKey(name: 'completed_at') this.completedAt,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserLessonProgress.fromJson(Map<String, dynamic> json) =>
      _$UserLessonProgressFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'lesson_id')
  final String lessonId;
  @override
  @JsonKey()
  final String status;
  @override
  final int? score;
  @override
  @JsonKey(name: 'attempts_count')
  final int attemptsCount;
  @override
  @JsonKey(name: 'best_score')
  final double? bestScore;
  @override
  @JsonKey(name: 'total_time_spent')
  final int totalTimeSpent;
  @override
  @JsonKey(name: 'mastery_score')
  final double? masteryScore;
  @override
  @JsonKey(name: 'mastery_level')
  final int masteryLevel;
  @override
  @JsonKey(name: 'last_attempt_at')
  final DateTime? lastAttemptAt;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of UserLessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserLessonProgressCopyWith<_UserLessonProgress> get copyWith =>
      __$UserLessonProgressCopyWithImpl<_UserLessonProgress>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserLessonProgressToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserLessonProgress &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.attemptsCount, attemptsCount) ||
                other.attemptsCount == attemptsCount) &&
            (identical(other.bestScore, bestScore) ||
                other.bestScore == bestScore) &&
            (identical(other.totalTimeSpent, totalTimeSpent) ||
                other.totalTimeSpent == totalTimeSpent) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            (identical(other.lastAttemptAt, lastAttemptAt) ||
                other.lastAttemptAt == lastAttemptAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
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
      userId,
      lessonId,
      status,
      score,
      attemptsCount,
      bestScore,
      totalTimeSpent,
      masteryScore,
      masteryLevel,
      lastAttemptAt,
      completedAt,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'UserLessonProgress(id: $id, userId: $userId, lessonId: $lessonId, status: $status, score: $score, attemptsCount: $attemptsCount, bestScore: $bestScore, totalTimeSpent: $totalTimeSpent, masteryScore: $masteryScore, masteryLevel: $masteryLevel, lastAttemptAt: $lastAttemptAt, completedAt: $completedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$UserLessonProgressCopyWith<$Res>
    implements $UserLessonProgressCopyWith<$Res> {
  factory _$UserLessonProgressCopyWith(
          _UserLessonProgress value, $Res Function(_UserLessonProgress) _then) =
      __$UserLessonProgressCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'lesson_id') String lessonId,
      String status,
      int? score,
      @JsonKey(name: 'attempts_count') int attemptsCount,
      @JsonKey(name: 'best_score') double? bestScore,
      @JsonKey(name: 'total_time_spent') int totalTimeSpent,
      @JsonKey(name: 'mastery_score') double? masteryScore,
      @JsonKey(name: 'mastery_level') int masteryLevel,
      @JsonKey(name: 'last_attempt_at') DateTime? lastAttemptAt,
      @JsonKey(name: 'completed_at') DateTime? completedAt,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$UserLessonProgressCopyWithImpl<$Res>
    implements _$UserLessonProgressCopyWith<$Res> {
  __$UserLessonProgressCopyWithImpl(this._self, this._then);

  final _UserLessonProgress _self;
  final $Res Function(_UserLessonProgress) _then;

  /// Create a copy of UserLessonProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? lessonId = null,
    Object? status = null,
    Object? score = freezed,
    Object? attemptsCount = null,
    Object? bestScore = freezed,
    Object? totalTimeSpent = null,
    Object? masteryScore = freezed,
    Object? masteryLevel = null,
    Object? lastAttemptAt = freezed,
    Object? completedAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_UserLessonProgress(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      score: freezed == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      attemptsCount: null == attemptsCount
          ? _self.attemptsCount
          : attemptsCount // ignore: cast_nullable_to_non_nullable
              as int,
      bestScore: freezed == bestScore
          ? _self.bestScore
          : bestScore // ignore: cast_nullable_to_non_nullable
              as double?,
      totalTimeSpent: null == totalTimeSpent
          ? _self.totalTimeSpent
          : totalTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      masteryScore: freezed == masteryScore
          ? _self.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double?,
      masteryLevel: null == masteryLevel
          ? _self.masteryLevel
          : masteryLevel // ignore: cast_nullable_to_non_nullable
              as int,
      lastAttemptAt: freezed == lastAttemptAt
          ? _self.lastAttemptAt
          : lastAttemptAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
mixin _$PronunciationSession {
  String get id;
  String get userId;
  String? get lessonId;
  String get audioFileUrl;
  String? get transcriptExpected;
  String? get transcriptActual;
  double? get overallScore;
  double? get accuracyScore;
  double? get fluencyScore;
  double? get completenessScore;
  Map<String, dynamic>? get wordLevelScores;
  Map<String, dynamic>? get phonemeAnalysis;
  String? get feedbackSummary;
  List<String> get improvementSuggestions;
  int? get sessionDuration;
  DateTime? get createdAt;

  /// Create a copy of PronunciationSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PronunciationSessionCopyWith<PronunciationSession> get copyWith =>
      _$PronunciationSessionCopyWithImpl<PronunciationSession>(
          this as PronunciationSession, _$identity);

  /// Serializes this PronunciationSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PronunciationSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.audioFileUrl, audioFileUrl) ||
                other.audioFileUrl == audioFileUrl) &&
            (identical(other.transcriptExpected, transcriptExpected) ||
                other.transcriptExpected == transcriptExpected) &&
            (identical(other.transcriptActual, transcriptActual) ||
                other.transcriptActual == transcriptActual) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.accuracyScore, accuracyScore) ||
                other.accuracyScore == accuracyScore) &&
            (identical(other.fluencyScore, fluencyScore) ||
                other.fluencyScore == fluencyScore) &&
            (identical(other.completenessScore, completenessScore) ||
                other.completenessScore == completenessScore) &&
            const DeepCollectionEquality()
                .equals(other.wordLevelScores, wordLevelScores) &&
            const DeepCollectionEquality()
                .equals(other.phonemeAnalysis, phonemeAnalysis) &&
            (identical(other.feedbackSummary, feedbackSummary) ||
                other.feedbackSummary == feedbackSummary) &&
            const DeepCollectionEquality()
                .equals(other.improvementSuggestions, improvementSuggestions) &&
            (identical(other.sessionDuration, sessionDuration) ||
                other.sessionDuration == sessionDuration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      lessonId,
      audioFileUrl,
      transcriptExpected,
      transcriptActual,
      overallScore,
      accuracyScore,
      fluencyScore,
      completenessScore,
      const DeepCollectionEquality().hash(wordLevelScores),
      const DeepCollectionEquality().hash(phonemeAnalysis),
      feedbackSummary,
      const DeepCollectionEquality().hash(improvementSuggestions),
      sessionDuration,
      createdAt);

  @override
  String toString() {
    return 'PronunciationSession(id: $id, userId: $userId, lessonId: $lessonId, audioFileUrl: $audioFileUrl, transcriptExpected: $transcriptExpected, transcriptActual: $transcriptActual, overallScore: $overallScore, accuracyScore: $accuracyScore, fluencyScore: $fluencyScore, completenessScore: $completenessScore, wordLevelScores: $wordLevelScores, phonemeAnalysis: $phonemeAnalysis, feedbackSummary: $feedbackSummary, improvementSuggestions: $improvementSuggestions, sessionDuration: $sessionDuration, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PronunciationSessionCopyWith<$Res> {
  factory $PronunciationSessionCopyWith(PronunciationSession value,
          $Res Function(PronunciationSession) _then) =
      _$PronunciationSessionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? lessonId,
      String audioFileUrl,
      String? transcriptExpected,
      String? transcriptActual,
      double? overallScore,
      double? accuracyScore,
      double? fluencyScore,
      double? completenessScore,
      Map<String, dynamic>? wordLevelScores,
      Map<String, dynamic>? phonemeAnalysis,
      String? feedbackSummary,
      List<String> improvementSuggestions,
      int? sessionDuration,
      DateTime? createdAt});
}

/// @nodoc
class _$PronunciationSessionCopyWithImpl<$Res>
    implements $PronunciationSessionCopyWith<$Res> {
  _$PronunciationSessionCopyWithImpl(this._self, this._then);

  final PronunciationSession _self;
  final $Res Function(PronunciationSession) _then;

  /// Create a copy of PronunciationSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lessonId = freezed,
    Object? audioFileUrl = null,
    Object? transcriptExpected = freezed,
    Object? transcriptActual = freezed,
    Object? overallScore = freezed,
    Object? accuracyScore = freezed,
    Object? fluencyScore = freezed,
    Object? completenessScore = freezed,
    Object? wordLevelScores = freezed,
    Object? phonemeAnalysis = freezed,
    Object? feedbackSummary = freezed,
    Object? improvementSuggestions = null,
    Object? sessionDuration = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: freezed == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      audioFileUrl: null == audioFileUrl
          ? _self.audioFileUrl
          : audioFileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      transcriptExpected: freezed == transcriptExpected
          ? _self.transcriptExpected
          : transcriptExpected // ignore: cast_nullable_to_non_nullable
              as String?,
      transcriptActual: freezed == transcriptActual
          ? _self.transcriptActual
          : transcriptActual // ignore: cast_nullable_to_non_nullable
              as String?,
      overallScore: freezed == overallScore
          ? _self.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double?,
      accuracyScore: freezed == accuracyScore
          ? _self.accuracyScore
          : accuracyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      fluencyScore: freezed == fluencyScore
          ? _self.fluencyScore
          : fluencyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      completenessScore: freezed == completenessScore
          ? _self.completenessScore
          : completenessScore // ignore: cast_nullable_to_non_nullable
              as double?,
      wordLevelScores: freezed == wordLevelScores
          ? _self.wordLevelScores
          : wordLevelScores // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      phonemeAnalysis: freezed == phonemeAnalysis
          ? _self.phonemeAnalysis
          : phonemeAnalysis // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      feedbackSummary: freezed == feedbackSummary
          ? _self.feedbackSummary
          : feedbackSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementSuggestions: null == improvementSuggestions
          ? _self.improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sessionDuration: freezed == sessionDuration
          ? _self.sessionDuration
          : sessionDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _PronunciationSession implements PronunciationSession {
  const _PronunciationSession(
      {required this.id,
      required this.userId,
      this.lessonId,
      required this.audioFileUrl,
      this.transcriptExpected,
      this.transcriptActual,
      this.overallScore,
      this.accuracyScore,
      this.fluencyScore,
      this.completenessScore,
      final Map<String, dynamic>? wordLevelScores,
      final Map<String, dynamic>? phonemeAnalysis,
      this.feedbackSummary,
      final List<String> improvementSuggestions = const [],
      this.sessionDuration,
      this.createdAt})
      : _wordLevelScores = wordLevelScores,
        _phonemeAnalysis = phonemeAnalysis,
        _improvementSuggestions = improvementSuggestions;
  factory _PronunciationSession.fromJson(Map<String, dynamic> json) =>
      _$PronunciationSessionFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? lessonId;
  @override
  final String audioFileUrl;
  @override
  final String? transcriptExpected;
  @override
  final String? transcriptActual;
  @override
  final double? overallScore;
  @override
  final double? accuracyScore;
  @override
  final double? fluencyScore;
  @override
  final double? completenessScore;
  final Map<String, dynamic>? _wordLevelScores;
  @override
  Map<String, dynamic>? get wordLevelScores {
    final value = _wordLevelScores;
    if (value == null) return null;
    if (_wordLevelScores is EqualUnmodifiableMapView) return _wordLevelScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _phonemeAnalysis;
  @override
  Map<String, dynamic>? get phonemeAnalysis {
    final value = _phonemeAnalysis;
    if (value == null) return null;
    if (_phonemeAnalysis is EqualUnmodifiableMapView) return _phonemeAnalysis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? feedbackSummary;
  final List<String> _improvementSuggestions;
  @override
  @JsonKey()
  List<String> get improvementSuggestions {
    if (_improvementSuggestions is EqualUnmodifiableListView)
      return _improvementSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvementSuggestions);
  }

  @override
  final int? sessionDuration;
  @override
  final DateTime? createdAt;

  /// Create a copy of PronunciationSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PronunciationSessionCopyWith<_PronunciationSession> get copyWith =>
      __$PronunciationSessionCopyWithImpl<_PronunciationSession>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PronunciationSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PronunciationSession &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.audioFileUrl, audioFileUrl) ||
                other.audioFileUrl == audioFileUrl) &&
            (identical(other.transcriptExpected, transcriptExpected) ||
                other.transcriptExpected == transcriptExpected) &&
            (identical(other.transcriptActual, transcriptActual) ||
                other.transcriptActual == transcriptActual) &&
            (identical(other.overallScore, overallScore) ||
                other.overallScore == overallScore) &&
            (identical(other.accuracyScore, accuracyScore) ||
                other.accuracyScore == accuracyScore) &&
            (identical(other.fluencyScore, fluencyScore) ||
                other.fluencyScore == fluencyScore) &&
            (identical(other.completenessScore, completenessScore) ||
                other.completenessScore == completenessScore) &&
            const DeepCollectionEquality()
                .equals(other._wordLevelScores, _wordLevelScores) &&
            const DeepCollectionEquality()
                .equals(other._phonemeAnalysis, _phonemeAnalysis) &&
            (identical(other.feedbackSummary, feedbackSummary) ||
                other.feedbackSummary == feedbackSummary) &&
            const DeepCollectionEquality().equals(
                other._improvementSuggestions, _improvementSuggestions) &&
            (identical(other.sessionDuration, sessionDuration) ||
                other.sessionDuration == sessionDuration) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      lessonId,
      audioFileUrl,
      transcriptExpected,
      transcriptActual,
      overallScore,
      accuracyScore,
      fluencyScore,
      completenessScore,
      const DeepCollectionEquality().hash(_wordLevelScores),
      const DeepCollectionEquality().hash(_phonemeAnalysis),
      feedbackSummary,
      const DeepCollectionEquality().hash(_improvementSuggestions),
      sessionDuration,
      createdAt);

  @override
  String toString() {
    return 'PronunciationSession(id: $id, userId: $userId, lessonId: $lessonId, audioFileUrl: $audioFileUrl, transcriptExpected: $transcriptExpected, transcriptActual: $transcriptActual, overallScore: $overallScore, accuracyScore: $accuracyScore, fluencyScore: $fluencyScore, completenessScore: $completenessScore, wordLevelScores: $wordLevelScores, phonemeAnalysis: $phonemeAnalysis, feedbackSummary: $feedbackSummary, improvementSuggestions: $improvementSuggestions, sessionDuration: $sessionDuration, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PronunciationSessionCopyWith<$Res>
    implements $PronunciationSessionCopyWith<$Res> {
  factory _$PronunciationSessionCopyWith(_PronunciationSession value,
          $Res Function(_PronunciationSession) _then) =
      __$PronunciationSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? lessonId,
      String audioFileUrl,
      String? transcriptExpected,
      String? transcriptActual,
      double? overallScore,
      double? accuracyScore,
      double? fluencyScore,
      double? completenessScore,
      Map<String, dynamic>? wordLevelScores,
      Map<String, dynamic>? phonemeAnalysis,
      String? feedbackSummary,
      List<String> improvementSuggestions,
      int? sessionDuration,
      DateTime? createdAt});
}

/// @nodoc
class __$PronunciationSessionCopyWithImpl<$Res>
    implements _$PronunciationSessionCopyWith<$Res> {
  __$PronunciationSessionCopyWithImpl(this._self, this._then);

  final _PronunciationSession _self;
  final $Res Function(_PronunciationSession) _then;

  /// Create a copy of PronunciationSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? lessonId = freezed,
    Object? audioFileUrl = null,
    Object? transcriptExpected = freezed,
    Object? transcriptActual = freezed,
    Object? overallScore = freezed,
    Object? accuracyScore = freezed,
    Object? fluencyScore = freezed,
    Object? completenessScore = freezed,
    Object? wordLevelScores = freezed,
    Object? phonemeAnalysis = freezed,
    Object? feedbackSummary = freezed,
    Object? improvementSuggestions = null,
    Object? sessionDuration = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_PronunciationSession(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: freezed == lessonId
          ? _self.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String?,
      audioFileUrl: null == audioFileUrl
          ? _self.audioFileUrl
          : audioFileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      transcriptExpected: freezed == transcriptExpected
          ? _self.transcriptExpected
          : transcriptExpected // ignore: cast_nullable_to_non_nullable
              as String?,
      transcriptActual: freezed == transcriptActual
          ? _self.transcriptActual
          : transcriptActual // ignore: cast_nullable_to_non_nullable
              as String?,
      overallScore: freezed == overallScore
          ? _self.overallScore
          : overallScore // ignore: cast_nullable_to_non_nullable
              as double?,
      accuracyScore: freezed == accuracyScore
          ? _self.accuracyScore
          : accuracyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      fluencyScore: freezed == fluencyScore
          ? _self.fluencyScore
          : fluencyScore // ignore: cast_nullable_to_non_nullable
              as double?,
      completenessScore: freezed == completenessScore
          ? _self.completenessScore
          : completenessScore // ignore: cast_nullable_to_non_nullable
              as double?,
      wordLevelScores: freezed == wordLevelScores
          ? _self._wordLevelScores
          : wordLevelScores // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      phonemeAnalysis: freezed == phonemeAnalysis
          ? _self._phonemeAnalysis
          : phonemeAnalysis // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      feedbackSummary: freezed == feedbackSummary
          ? _self.feedbackSummary
          : feedbackSummary // ignore: cast_nullable_to_non_nullable
              as String?,
      improvementSuggestions: null == improvementSuggestions
          ? _self._improvementSuggestions
          : improvementSuggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sessionDuration: freezed == sessionDuration
          ? _self.sessionDuration
          : sessionDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$Achievement {
  String get id;
  String get title;
  String? get description;
  String get category;
  String? get badgeIconUrl;
  String get rarity;
  int get xpReward;
  Map<String, dynamic> get unlockCriteria;
  bool get isHidden;
  DateTime? get createdAt;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AchievementCopyWith<Achievement> get copyWith =>
      _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Achievement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.badgeIconUrl, badgeIconUrl) ||
                other.badgeIconUrl == badgeIconUrl) &&
            (identical(other.rarity, rarity) || other.rarity == rarity) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            const DeepCollectionEquality()
                .equals(other.unlockCriteria, unlockCriteria) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      badgeIconUrl,
      rarity,
      xpReward,
      const DeepCollectionEquality().hash(unlockCriteria),
      isHidden,
      createdAt);

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, category: $category, badgeIconUrl: $badgeIconUrl, rarity: $rarity, xpReward: $xpReward, unlockCriteria: $unlockCriteria, isHidden: $isHidden, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) _then) =
      _$AchievementCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String category,
      String? badgeIconUrl,
      String rarity,
      int xpReward,
      Map<String, dynamic> unlockCriteria,
      bool isHidden,
      DateTime? createdAt});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res> implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? badgeIconUrl = freezed,
    Object? rarity = null,
    Object? xpReward = null,
    Object? unlockCriteria = null,
    Object? isHidden = null,
    Object? createdAt = freezed,
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
      badgeIconUrl: freezed == badgeIconUrl
          ? _self.badgeIconUrl
          : badgeIconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rarity: null == rarity
          ? _self.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as String,
      xpReward: null == xpReward
          ? _self.xpReward
          : xpReward // ignore: cast_nullable_to_non_nullable
              as int,
      unlockCriteria: null == unlockCriteria
          ? _self.unlockCriteria
          : unlockCriteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isHidden: null == isHidden
          ? _self.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Achievement implements Achievement {
  const _Achievement(
      {required this.id,
      required this.title,
      this.description,
      required this.category,
      this.badgeIconUrl,
      this.rarity = 'common',
      this.xpReward = 0,
      required final Map<String, dynamic> unlockCriteria,
      this.isHidden = false,
      this.createdAt})
      : _unlockCriteria = unlockCriteria;
  factory _Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String category;
  @override
  final String? badgeIconUrl;
  @override
  @JsonKey()
  final String rarity;
  @override
  @JsonKey()
  final int xpReward;
  final Map<String, dynamic> _unlockCriteria;
  @override
  Map<String, dynamic> get unlockCriteria {
    if (_unlockCriteria is EqualUnmodifiableMapView) return _unlockCriteria;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_unlockCriteria);
  }

  @override
  @JsonKey()
  final bool isHidden;
  @override
  final DateTime? createdAt;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AchievementCopyWith<_Achievement> get copyWith =>
      __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AchievementToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Achievement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.badgeIconUrl, badgeIconUrl) ||
                other.badgeIconUrl == badgeIconUrl) &&
            (identical(other.rarity, rarity) || other.rarity == rarity) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            const DeepCollectionEquality()
                .equals(other._unlockCriteria, _unlockCriteria) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      badgeIconUrl,
      rarity,
      xpReward,
      const DeepCollectionEquality().hash(_unlockCriteria),
      isHidden,
      createdAt);

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, category: $category, badgeIconUrl: $badgeIconUrl, rarity: $rarity, xpReward: $xpReward, unlockCriteria: $unlockCriteria, isHidden: $isHidden, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(
          _Achievement value, $Res Function(_Achievement) _then) =
      __$AchievementCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String category,
      String? badgeIconUrl,
      String rarity,
      int xpReward,
      Map<String, dynamic> unlockCriteria,
      bool isHidden,
      DateTime? createdAt});
}

/// @nodoc
class __$AchievementCopyWithImpl<$Res> implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? category = null,
    Object? badgeIconUrl = freezed,
    Object? rarity = null,
    Object? xpReward = null,
    Object? unlockCriteria = null,
    Object? isHidden = null,
    Object? createdAt = freezed,
  }) {
    return _then(_Achievement(
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
      badgeIconUrl: freezed == badgeIconUrl
          ? _self.badgeIconUrl
          : badgeIconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rarity: null == rarity
          ? _self.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as String,
      xpReward: null == xpReward
          ? _self.xpReward
          : xpReward // ignore: cast_nullable_to_non_nullable
              as int,
      unlockCriteria: null == unlockCriteria
          ? _self._unlockCriteria
          : unlockCriteria // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isHidden: null == isHidden
          ? _self.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$UserAchievement {
  String? get id;
  String get userId;
  String get achievementId;
  DateTime get unlockedAt;
  Map<String, dynamic>? get progressData;

  /// Create a copy of UserAchievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserAchievementCopyWith<UserAchievement> get copyWith =>
      _$UserAchievementCopyWithImpl<UserAchievement>(
          this as UserAchievement, _$identity);

  /// Serializes this UserAchievement to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserAchievement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.achievementId, achievementId) ||
                other.achievementId == achievementId) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            const DeepCollectionEquality()
                .equals(other.progressData, progressData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, achievementId,
      unlockedAt, const DeepCollectionEquality().hash(progressData));

  @override
  String toString() {
    return 'UserAchievement(id: $id, userId: $userId, achievementId: $achievementId, unlockedAt: $unlockedAt, progressData: $progressData)';
  }
}

/// @nodoc
abstract mixin class $UserAchievementCopyWith<$Res> {
  factory $UserAchievementCopyWith(
          UserAchievement value, $Res Function(UserAchievement) _then) =
      _$UserAchievementCopyWithImpl;
  @useResult
  $Res call(
      {String? id,
      String userId,
      String achievementId,
      DateTime unlockedAt,
      Map<String, dynamic>? progressData});
}

/// @nodoc
class _$UserAchievementCopyWithImpl<$Res>
    implements $UserAchievementCopyWith<$Res> {
  _$UserAchievementCopyWithImpl(this._self, this._then);

  final UserAchievement _self;
  final $Res Function(UserAchievement) _then;

  /// Create a copy of UserAchievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? achievementId = null,
    Object? unlockedAt = null,
    Object? progressData = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      achievementId: null == achievementId
          ? _self.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      unlockedAt: null == unlockedAt
          ? _self.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progressData: freezed == progressData
          ? _self.progressData
          : progressData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _UserAchievement implements UserAchievement {
  const _UserAchievement(
      {this.id,
      required this.userId,
      required this.achievementId,
      required this.unlockedAt,
      final Map<String, dynamic>? progressData})
      : _progressData = progressData;
  factory _UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);

  @override
  final String? id;
  @override
  final String userId;
  @override
  final String achievementId;
  @override
  final DateTime unlockedAt;
  final Map<String, dynamic>? _progressData;
  @override
  Map<String, dynamic>? get progressData {
    final value = _progressData;
    if (value == null) return null;
    if (_progressData is EqualUnmodifiableMapView) return _progressData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of UserAchievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserAchievementCopyWith<_UserAchievement> get copyWith =>
      __$UserAchievementCopyWithImpl<_UserAchievement>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserAchievementToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserAchievement &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.achievementId, achievementId) ||
                other.achievementId == achievementId) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            const DeepCollectionEquality()
                .equals(other._progressData, _progressData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, achievementId,
      unlockedAt, const DeepCollectionEquality().hash(_progressData));

  @override
  String toString() {
    return 'UserAchievement(id: $id, userId: $userId, achievementId: $achievementId, unlockedAt: $unlockedAt, progressData: $progressData)';
  }
}

/// @nodoc
abstract mixin class _$UserAchievementCopyWith<$Res>
    implements $UserAchievementCopyWith<$Res> {
  factory _$UserAchievementCopyWith(
          _UserAchievement value, $Res Function(_UserAchievement) _then) =
      __$UserAchievementCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? id,
      String userId,
      String achievementId,
      DateTime unlockedAt,
      Map<String, dynamic>? progressData});
}

/// @nodoc
class __$UserAchievementCopyWithImpl<$Res>
    implements _$UserAchievementCopyWith<$Res> {
  __$UserAchievementCopyWithImpl(this._self, this._then);

  final _UserAchievement _self;
  final $Res Function(_UserAchievement) _then;

  /// Create a copy of UserAchievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? achievementId = null,
    Object? unlockedAt = null,
    Object? progressData = freezed,
  }) {
    return _then(_UserAchievement(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      achievementId: null == achievementId
          ? _self.achievementId
          : achievementId // ignore: cast_nullable_to_non_nullable
              as String,
      unlockedAt: null == unlockedAt
          ? _self.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      progressData: freezed == progressData
          ? _self._progressData
          : progressData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$LessonModel {
  String get id;
  @JsonKey(name: 'curriculum_id')
  String get curriculumId;
  String get title;
  String get description;
  @JsonKey(name: 'order_index')
  int get orderIndex;
  @JsonKey(fromJson: _lessonTypeFromJson)
  LessonType get type;
  @JsonKey(name: 'estimated_minutes')
  int get estimatedMinutes;
  @JsonKey(fromJson: _difficultyFromJson)
  DifficultyLevel get difficulty;
  @JsonKey(fromJson: _objectivesFromJson)
  List<String> get objectives;
  @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson)
  List<KeyPhrase> get keyPhrases;
  @JsonKey(fromJson: _dialoguesFromJson)
  List<Map<String, dynamic>> get dialogues;
  @JsonKey(name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson)
  List<Map<String, dynamic>> get vocabularyQuestions;
  @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson)
  List<GrammarPoint> get grammarPoints;
  @JsonKey(name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson)
  PronunciationFocus? get pronunciationFocus;
  @JsonKey(name: 'character_id', fromJson: _characterIdFromJson)
  String get characterId;
  bool get isCompleted;
  double get completionRate;
  DateTime? get lastAccessedAt;
  Map<String, dynamic>? get metadata;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LessonModelCopyWith<LessonModel> get copyWith =>
      _$LessonModelCopyWithImpl<LessonModel>(this as LessonModel, _$identity);

  /// Serializes this LessonModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LessonModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.curriculumId, curriculumId) ||
                other.curriculumId == curriculumId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other.objectives, objectives) &&
            const DeepCollectionEquality()
                .equals(other.keyPhrases, keyPhrases) &&
            const DeepCollectionEquality().equals(other.dialogues, dialogues) &&
            const DeepCollectionEquality()
                .equals(other.vocabularyQuestions, vocabularyQuestions) &&
            const DeepCollectionEquality()
                .equals(other.grammarPoints, grammarPoints) &&
            (identical(other.pronunciationFocus, pronunciationFocus) ||
                other.pronunciationFocus == pronunciationFocus) &&
            (identical(other.characterId, characterId) ||
                other.characterId == characterId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        curriculumId,
        title,
        description,
        orderIndex,
        type,
        estimatedMinutes,
        difficulty,
        const DeepCollectionEquality().hash(objectives),
        const DeepCollectionEquality().hash(keyPhrases),
        const DeepCollectionEquality().hash(dialogues),
        const DeepCollectionEquality().hash(vocabularyQuestions),
        const DeepCollectionEquality().hash(grammarPoints),
        pronunciationFocus,
        characterId,
        isCompleted,
        completionRate,
        lastAccessedAt,
        const DeepCollectionEquality().hash(metadata)
      ]);

  @override
  String toString() {
    return 'LessonModel(id: $id, curriculumId: $curriculumId, title: $title, description: $description, orderIndex: $orderIndex, type: $type, estimatedMinutes: $estimatedMinutes, difficulty: $difficulty, objectives: $objectives, keyPhrases: $keyPhrases, dialogues: $dialogues, vocabularyQuestions: $vocabularyQuestions, grammarPoints: $grammarPoints, pronunciationFocus: $pronunciationFocus, characterId: $characterId, isCompleted: $isCompleted, completionRate: $completionRate, lastAccessedAt: $lastAccessedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $LessonModelCopyWith<$Res> {
  factory $LessonModelCopyWith(
          LessonModel value, $Res Function(LessonModel) _then) =
      _$LessonModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'curriculum_id') String curriculumId,
      String title,
      String description,
      @JsonKey(name: 'order_index') int orderIndex,
      @JsonKey(fromJson: _lessonTypeFromJson) LessonType type,
      @JsonKey(name: 'estimated_minutes') int estimatedMinutes,
      @JsonKey(fromJson: _difficultyFromJson) DifficultyLevel difficulty,
      @JsonKey(fromJson: _objectivesFromJson) List<String> objectives,
      @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson)
      List<KeyPhrase> keyPhrases,
      @JsonKey(fromJson: _dialoguesFromJson)
      List<Map<String, dynamic>> dialogues,
      @JsonKey(
          name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson)
      List<Map<String, dynamic>> vocabularyQuestions,
      @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson)
      List<GrammarPoint> grammarPoints,
      @JsonKey(
          name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson)
      PronunciationFocus? pronunciationFocus,
      @JsonKey(name: 'character_id', fromJson: _characterIdFromJson)
      String characterId,
      bool isCompleted,
      double completionRate,
      DateTime? lastAccessedAt,
      Map<String, dynamic>? metadata});

  $PronunciationFocusCopyWith<$Res>? get pronunciationFocus;
}

/// @nodoc
class _$LessonModelCopyWithImpl<$Res> implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._self, this._then);

  final LessonModel _self;
  final $Res Function(LessonModel) _then;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? curriculumId = null,
    Object? title = null,
    Object? description = null,
    Object? orderIndex = null,
    Object? type = null,
    Object? estimatedMinutes = null,
    Object? difficulty = null,
    Object? objectives = null,
    Object? keyPhrases = null,
    Object? dialogues = null,
    Object? vocabularyQuestions = null,
    Object? grammarPoints = null,
    Object? pronunciationFocus = freezed,
    Object? characterId = null,
    Object? isCompleted = null,
    Object? completionRate = null,
    Object? lastAccessedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      curriculumId: null == curriculumId
          ? _self.curriculumId
          : curriculumId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as LessonType,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DifficultyLevel,
      objectives: null == objectives
          ? _self.objectives
          : objectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      keyPhrases: null == keyPhrases
          ? _self.keyPhrases
          : keyPhrases // ignore: cast_nullable_to_non_nullable
              as List<KeyPhrase>,
      dialogues: null == dialogues
          ? _self.dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      vocabularyQuestions: null == vocabularyQuestions
          ? _self.vocabularyQuestions
          : vocabularyQuestions // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      grammarPoints: null == grammarPoints
          ? _self.grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<GrammarPoint>,
      pronunciationFocus: freezed == pronunciationFocus
          ? _self.pronunciationFocus
          : pronunciationFocus // ignore: cast_nullable_to_non_nullable
              as PronunciationFocus?,
      characterId: null == characterId
          ? _self.characterId
          : characterId // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      lastAccessedAt: freezed == lastAccessedAt
          ? _self.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PronunciationFocusCopyWith<$Res>? get pronunciationFocus {
    if (_self.pronunciationFocus == null) {
      return null;
    }

    return $PronunciationFocusCopyWith<$Res>(_self.pronunciationFocus!,
        (value) {
      return _then(_self.copyWith(pronunciationFocus: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _LessonModel implements LessonModel {
  const _LessonModel(
      {required this.id,
      @JsonKey(name: 'curriculum_id') required this.curriculumId,
      required this.title,
      this.description = '',
      @JsonKey(name: 'order_index') this.orderIndex = 0,
      @JsonKey(fromJson: _lessonTypeFromJson) required this.type,
      @JsonKey(name: 'estimated_minutes') this.estimatedMinutes = 30,
      @JsonKey(fromJson: _difficultyFromJson) required this.difficulty,
      @JsonKey(fromJson: _objectivesFromJson)
      final List<String> objectives = const [],
      @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson)
      final List<KeyPhrase> keyPhrases = const [],
      @JsonKey(fromJson: _dialoguesFromJson)
      final List<Map<String, dynamic>> dialogues = const [],
      @JsonKey(
          name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson)
      final List<Map<String, dynamic>> vocabularyQuestions = const [],
      @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson)
      final List<GrammarPoint> grammarPoints = const [],
      @JsonKey(
          name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson)
      this.pronunciationFocus,
      @JsonKey(name: 'character_id', fromJson: _characterIdFromJson)
      this.characterId = 'sarah',
      this.isCompleted = false,
      this.completionRate = 0,
      this.lastAccessedAt,
      final Map<String, dynamic>? metadata})
      : _objectives = objectives,
        _keyPhrases = keyPhrases,
        _dialogues = dialogues,
        _vocabularyQuestions = vocabularyQuestions,
        _grammarPoints = grammarPoints,
        _metadata = metadata;
  factory _LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'curriculum_id')
  final String curriculumId;
  @override
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'order_index')
  final int orderIndex;
  @override
  @JsonKey(fromJson: _lessonTypeFromJson)
  final LessonType type;
  @override
  @JsonKey(name: 'estimated_minutes')
  final int estimatedMinutes;
  @override
  @JsonKey(fromJson: _difficultyFromJson)
  final DifficultyLevel difficulty;
  final List<String> _objectives;
  @override
  @JsonKey(fromJson: _objectivesFromJson)
  List<String> get objectives {
    if (_objectives is EqualUnmodifiableListView) return _objectives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_objectives);
  }

  final List<KeyPhrase> _keyPhrases;
  @override
  @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson)
  List<KeyPhrase> get keyPhrases {
    if (_keyPhrases is EqualUnmodifiableListView) return _keyPhrases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyPhrases);
  }

  final List<Map<String, dynamic>> _dialogues;
  @override
  @JsonKey(fromJson: _dialoguesFromJson)
  List<Map<String, dynamic>> get dialogues {
    if (_dialogues is EqualUnmodifiableListView) return _dialogues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dialogues);
  }

  final List<Map<String, dynamic>> _vocabularyQuestions;
  @override
  @JsonKey(name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson)
  List<Map<String, dynamic>> get vocabularyQuestions {
    if (_vocabularyQuestions is EqualUnmodifiableListView)
      return _vocabularyQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vocabularyQuestions);
  }

  final List<GrammarPoint> _grammarPoints;
  @override
  @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson)
  List<GrammarPoint> get grammarPoints {
    if (_grammarPoints is EqualUnmodifiableListView) return _grammarPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_grammarPoints);
  }

  @override
  @JsonKey(name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson)
  final PronunciationFocus? pronunciationFocus;
  @override
  @JsonKey(name: 'character_id', fromJson: _characterIdFromJson)
  final String characterId;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final double completionRate;
  @override
  final DateTime? lastAccessedAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LessonModelCopyWith<_LessonModel> get copyWith =>
      __$LessonModelCopyWithImpl<_LessonModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LessonModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LessonModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.curriculumId, curriculumId) ||
                other.curriculumId == curriculumId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._objectives, _objectives) &&
            const DeepCollectionEquality()
                .equals(other._keyPhrases, _keyPhrases) &&
            const DeepCollectionEquality()
                .equals(other._dialogues, _dialogues) &&
            const DeepCollectionEquality()
                .equals(other._vocabularyQuestions, _vocabularyQuestions) &&
            const DeepCollectionEquality()
                .equals(other._grammarPoints, _grammarPoints) &&
            (identical(other.pronunciationFocus, pronunciationFocus) ||
                other.pronunciationFocus == pronunciationFocus) &&
            (identical(other.characterId, characterId) ||
                other.characterId == characterId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.lastAccessedAt, lastAccessedAt) ||
                other.lastAccessedAt == lastAccessedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        curriculumId,
        title,
        description,
        orderIndex,
        type,
        estimatedMinutes,
        difficulty,
        const DeepCollectionEquality().hash(_objectives),
        const DeepCollectionEquality().hash(_keyPhrases),
        const DeepCollectionEquality().hash(_dialogues),
        const DeepCollectionEquality().hash(_vocabularyQuestions),
        const DeepCollectionEquality().hash(_grammarPoints),
        pronunciationFocus,
        characterId,
        isCompleted,
        completionRate,
        lastAccessedAt,
        const DeepCollectionEquality().hash(_metadata)
      ]);

  @override
  String toString() {
    return 'LessonModel(id: $id, curriculumId: $curriculumId, title: $title, description: $description, orderIndex: $orderIndex, type: $type, estimatedMinutes: $estimatedMinutes, difficulty: $difficulty, objectives: $objectives, keyPhrases: $keyPhrases, dialogues: $dialogues, vocabularyQuestions: $vocabularyQuestions, grammarPoints: $grammarPoints, pronunciationFocus: $pronunciationFocus, characterId: $characterId, isCompleted: $isCompleted, completionRate: $completionRate, lastAccessedAt: $lastAccessedAt, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$LessonModelCopyWith<$Res>
    implements $LessonModelCopyWith<$Res> {
  factory _$LessonModelCopyWith(
          _LessonModel value, $Res Function(_LessonModel) _then) =
      __$LessonModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'curriculum_id') String curriculumId,
      String title,
      String description,
      @JsonKey(name: 'order_index') int orderIndex,
      @JsonKey(fromJson: _lessonTypeFromJson) LessonType type,
      @JsonKey(name: 'estimated_minutes') int estimatedMinutes,
      @JsonKey(fromJson: _difficultyFromJson) DifficultyLevel difficulty,
      @JsonKey(fromJson: _objectivesFromJson) List<String> objectives,
      @JsonKey(name: 'key_phrases', fromJson: _keyPhrasesFromJson)
      List<KeyPhrase> keyPhrases,
      @JsonKey(fromJson: _dialoguesFromJson)
      List<Map<String, dynamic>> dialogues,
      @JsonKey(
          name: 'vocabulary_questions', fromJson: _vocabularyQuestionsFromJson)
      List<Map<String, dynamic>> vocabularyQuestions,
      @JsonKey(name: 'grammar_points_json', fromJson: _grammarPointsFromJson)
      List<GrammarPoint> grammarPoints,
      @JsonKey(
          name: 'pronunciation_focus', fromJson: _pronunciationFocusFromJson)
      PronunciationFocus? pronunciationFocus,
      @JsonKey(name: 'character_id', fromJson: _characterIdFromJson)
      String characterId,
      bool isCompleted,
      double completionRate,
      DateTime? lastAccessedAt,
      Map<String, dynamic>? metadata});

  @override
  $PronunciationFocusCopyWith<$Res>? get pronunciationFocus;
}

/// @nodoc
class __$LessonModelCopyWithImpl<$Res> implements _$LessonModelCopyWith<$Res> {
  __$LessonModelCopyWithImpl(this._self, this._then);

  final _LessonModel _self;
  final $Res Function(_LessonModel) _then;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? curriculumId = null,
    Object? title = null,
    Object? description = null,
    Object? orderIndex = null,
    Object? type = null,
    Object? estimatedMinutes = null,
    Object? difficulty = null,
    Object? objectives = null,
    Object? keyPhrases = null,
    Object? dialogues = null,
    Object? vocabularyQuestions = null,
    Object? grammarPoints = null,
    Object? pronunciationFocus = freezed,
    Object? characterId = null,
    Object? isCompleted = null,
    Object? completionRate = null,
    Object? lastAccessedAt = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_LessonModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      curriculumId: null == curriculumId
          ? _self.curriculumId
          : curriculumId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      orderIndex: null == orderIndex
          ? _self.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as LessonType,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _self.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DifficultyLevel,
      objectives: null == objectives
          ? _self._objectives
          : objectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      keyPhrases: null == keyPhrases
          ? _self._keyPhrases
          : keyPhrases // ignore: cast_nullable_to_non_nullable
              as List<KeyPhrase>,
      dialogues: null == dialogues
          ? _self._dialogues
          : dialogues // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      vocabularyQuestions: null == vocabularyQuestions
          ? _self._vocabularyQuestions
          : vocabularyQuestions // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      grammarPoints: null == grammarPoints
          ? _self._grammarPoints
          : grammarPoints // ignore: cast_nullable_to_non_nullable
              as List<GrammarPoint>,
      pronunciationFocus: freezed == pronunciationFocus
          ? _self.pronunciationFocus
          : pronunciationFocus // ignore: cast_nullable_to_non_nullable
              as PronunciationFocus?,
      characterId: null == characterId
          ? _self.characterId
          : characterId // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      lastAccessedAt: freezed == lastAccessedAt
          ? _self.lastAccessedAt
          : lastAccessedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PronunciationFocusCopyWith<$Res>? get pronunciationFocus {
    if (_self.pronunciationFocus == null) {
      return null;
    }

    return $PronunciationFocusCopyWith<$Res>(_self.pronunciationFocus!,
        (value) {
      return _then(_self.copyWith(pronunciationFocus: value));
    });
  }
}

/// @nodoc
mixin _$KeyPhrase {
  String get phrase;
  String get meaning;
  @JsonKey(name: 'phonetic')
  String? get pronunciation;
  @JsonKey(name: 'audio_url')
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
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.pronunciation, pronunciation) ||
                other.pronunciation == pronunciation) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, phrase, meaning, pronunciation, audioUrl);

  @override
  String toString() {
    return 'KeyPhrase(phrase: $phrase, meaning: $meaning, pronunciation: $pronunciation, audioUrl: $audioUrl)';
  }
}

/// @nodoc
abstract mixin class $KeyPhraseCopyWith<$Res> {
  factory $KeyPhraseCopyWith(KeyPhrase value, $Res Function(KeyPhrase) _then) =
      _$KeyPhraseCopyWithImpl;
  @useResult
  $Res call(
      {String phrase,
      String meaning,
      @JsonKey(name: 'phonetic') String? pronunciation,
      @JsonKey(name: 'audio_url') String? audioUrl});
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
    Object? meaning = null,
    Object? pronunciation = freezed,
    Object? audioUrl = freezed,
  }) {
    return _then(_self.copyWith(
      phrase: null == phrase
          ? _self.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      pronunciation: freezed == pronunciation
          ? _self.pronunciation
          : pronunciation // ignore: cast_nullable_to_non_nullable
              as String?,
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
      required this.meaning,
      @JsonKey(name: 'phonetic') this.pronunciation,
      @JsonKey(name: 'audio_url') this.audioUrl});
  factory _KeyPhrase.fromJson(Map<String, dynamic> json) =>
      _$KeyPhraseFromJson(json);

  @override
  final String phrase;
  @override
  final String meaning;
  @override
  @JsonKey(name: 'phonetic')
  final String? pronunciation;
  @override
  @JsonKey(name: 'audio_url')
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
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.pronunciation, pronunciation) ||
                other.pronunciation == pronunciation) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, phrase, meaning, pronunciation, audioUrl);

  @override
  String toString() {
    return 'KeyPhrase(phrase: $phrase, meaning: $meaning, pronunciation: $pronunciation, audioUrl: $audioUrl)';
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
      String meaning,
      @JsonKey(name: 'phonetic') String? pronunciation,
      @JsonKey(name: 'audio_url') String? audioUrl});
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
    Object? meaning = null,
    Object? pronunciation = freezed,
    Object? audioUrl = freezed,
  }) {
    return _then(_KeyPhrase(
      phrase: null == phrase
          ? _self.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      pronunciation: freezed == pronunciation
          ? _self.pronunciation
          : pronunciation // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _self.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$GrammarPoint {
  String get name;
  String get explanation;
  String get structure;
  List<String> get examples;
  List<String>? get commonMistakes;

  /// Create a copy of GrammarPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GrammarPointCopyWith<GrammarPoint> get copyWith =>
      _$GrammarPointCopyWithImpl<GrammarPoint>(
          this as GrammarPoint, _$identity);

  /// Serializes this GrammarPoint to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GrammarPoint &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            const DeepCollectionEquality().equals(other.examples, examples) &&
            const DeepCollectionEquality()
                .equals(other.commonMistakes, commonMistakes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      explanation,
      structure,
      const DeepCollectionEquality().hash(examples),
      const DeepCollectionEquality().hash(commonMistakes));

  @override
  String toString() {
    return 'GrammarPoint(name: $name, explanation: $explanation, structure: $structure, examples: $examples, commonMistakes: $commonMistakes)';
  }
}

/// @nodoc
abstract mixin class $GrammarPointCopyWith<$Res> {
  factory $GrammarPointCopyWith(
          GrammarPoint value, $Res Function(GrammarPoint) _then) =
      _$GrammarPointCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String explanation,
      String structure,
      List<String> examples,
      List<String>? commonMistakes});
}

/// @nodoc
class _$GrammarPointCopyWithImpl<$Res> implements $GrammarPointCopyWith<$Res> {
  _$GrammarPointCopyWithImpl(this._self, this._then);

  final GrammarPoint _self;
  final $Res Function(GrammarPoint) _then;

  /// Create a copy of GrammarPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? explanation = null,
    Object? structure = null,
    Object? examples = null,
    Object? commonMistakes = freezed,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      structure: null == structure
          ? _self.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as String,
      examples: null == examples
          ? _self.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: freezed == commonMistakes
          ? _self.commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _GrammarPoint implements GrammarPoint {
  const _GrammarPoint(
      {required this.name,
      required this.explanation,
      required this.structure,
      required final List<String> examples,
      final List<String>? commonMistakes})
      : _examples = examples,
        _commonMistakes = commonMistakes;
  factory _GrammarPoint.fromJson(Map<String, dynamic> json) =>
      _$GrammarPointFromJson(json);

  @override
  final String name;
  @override
  final String explanation;
  @override
  final String structure;
  final List<String> _examples;
  @override
  List<String> get examples {
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examples);
  }

  final List<String>? _commonMistakes;
  @override
  List<String>? get commonMistakes {
    final value = _commonMistakes;
    if (value == null) return null;
    if (_commonMistakes is EqualUnmodifiableListView) return _commonMistakes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of GrammarPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GrammarPointCopyWith<_GrammarPoint> get copyWith =>
      __$GrammarPointCopyWithImpl<_GrammarPoint>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GrammarPointToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GrammarPoint &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.structure, structure) ||
                other.structure == structure) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality()
                .equals(other._commonMistakes, _commonMistakes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      explanation,
      structure,
      const DeepCollectionEquality().hash(_examples),
      const DeepCollectionEquality().hash(_commonMistakes));

  @override
  String toString() {
    return 'GrammarPoint(name: $name, explanation: $explanation, structure: $structure, examples: $examples, commonMistakes: $commonMistakes)';
  }
}

/// @nodoc
abstract mixin class _$GrammarPointCopyWith<$Res>
    implements $GrammarPointCopyWith<$Res> {
  factory _$GrammarPointCopyWith(
          _GrammarPoint value, $Res Function(_GrammarPoint) _then) =
      __$GrammarPointCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String explanation,
      String structure,
      List<String> examples,
      List<String>? commonMistakes});
}

/// @nodoc
class __$GrammarPointCopyWithImpl<$Res>
    implements _$GrammarPointCopyWith<$Res> {
  __$GrammarPointCopyWithImpl(this._self, this._then);

  final _GrammarPoint _self;
  final $Res Function(_GrammarPoint) _then;

  /// Create a copy of GrammarPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? explanation = null,
    Object? structure = null,
    Object? examples = null,
    Object? commonMistakes = freezed,
  }) {
    return _then(_GrammarPoint(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      structure: null == structure
          ? _self.structure
          : structure // ignore: cast_nullable_to_non_nullable
              as String,
      examples: null == examples
          ? _self._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>,
      commonMistakes: freezed == commonMistakes
          ? _self._commonMistakes
          : commonMistakes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
mixin _$PronunciationFocus {
  List<String> get targetSounds;
  List<String> get words;
  List<String> get sentences;
  Map<String, String>? get tips;

  /// Create a copy of PronunciationFocus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PronunciationFocusCopyWith<PronunciationFocus> get copyWith =>
      _$PronunciationFocusCopyWithImpl<PronunciationFocus>(
          this as PronunciationFocus, _$identity);

  /// Serializes this PronunciationFocus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PronunciationFocus &&
            const DeepCollectionEquality()
                .equals(other.targetSounds, targetSounds) &&
            const DeepCollectionEquality().equals(other.words, words) &&
            const DeepCollectionEquality().equals(other.sentences, sentences) &&
            const DeepCollectionEquality().equals(other.tips, tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(targetSounds),
      const DeepCollectionEquality().hash(words),
      const DeepCollectionEquality().hash(sentences),
      const DeepCollectionEquality().hash(tips));

  @override
  String toString() {
    return 'PronunciationFocus(targetSounds: $targetSounds, words: $words, sentences: $sentences, tips: $tips)';
  }
}

/// @nodoc
abstract mixin class $PronunciationFocusCopyWith<$Res> {
  factory $PronunciationFocusCopyWith(
          PronunciationFocus value, $Res Function(PronunciationFocus) _then) =
      _$PronunciationFocusCopyWithImpl;
  @useResult
  $Res call(
      {List<String> targetSounds,
      List<String> words,
      List<String> sentences,
      Map<String, String>? tips});
}

/// @nodoc
class _$PronunciationFocusCopyWithImpl<$Res>
    implements $PronunciationFocusCopyWith<$Res> {
  _$PronunciationFocusCopyWithImpl(this._self, this._then);

  final PronunciationFocus _self;
  final $Res Function(PronunciationFocus) _then;

  /// Create a copy of PronunciationFocus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetSounds = null,
    Object? words = null,
    Object? sentences = null,
    Object? tips = freezed,
  }) {
    return _then(_self.copyWith(
      targetSounds: null == targetSounds
          ? _self.targetSounds
          : targetSounds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      words: null == words
          ? _self.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sentences: null == sentences
          ? _self.sentences
          : sentences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tips: freezed == tips
          ? _self.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _PronunciationFocus implements PronunciationFocus {
  const _PronunciationFocus(
      {required final List<String> targetSounds,
      required final List<String> words,
      required final List<String> sentences,
      final Map<String, String>? tips})
      : _targetSounds = targetSounds,
        _words = words,
        _sentences = sentences,
        _tips = tips;
  factory _PronunciationFocus.fromJson(Map<String, dynamic> json) =>
      _$PronunciationFocusFromJson(json);

  final List<String> _targetSounds;
  @override
  List<String> get targetSounds {
    if (_targetSounds is EqualUnmodifiableListView) return _targetSounds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targetSounds);
  }

  final List<String> _words;
  @override
  List<String> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  final List<String> _sentences;
  @override
  List<String> get sentences {
    if (_sentences is EqualUnmodifiableListView) return _sentences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sentences);
  }

  final Map<String, String>? _tips;
  @override
  Map<String, String>? get tips {
    final value = _tips;
    if (value == null) return null;
    if (_tips is EqualUnmodifiableMapView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of PronunciationFocus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PronunciationFocusCopyWith<_PronunciationFocus> get copyWith =>
      __$PronunciationFocusCopyWithImpl<_PronunciationFocus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PronunciationFocusToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PronunciationFocus &&
            const DeepCollectionEquality()
                .equals(other._targetSounds, _targetSounds) &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            const DeepCollectionEquality()
                .equals(other._sentences, _sentences) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_targetSounds),
      const DeepCollectionEquality().hash(_words),
      const DeepCollectionEquality().hash(_sentences),
      const DeepCollectionEquality().hash(_tips));

  @override
  String toString() {
    return 'PronunciationFocus(targetSounds: $targetSounds, words: $words, sentences: $sentences, tips: $tips)';
  }
}

/// @nodoc
abstract mixin class _$PronunciationFocusCopyWith<$Res>
    implements $PronunciationFocusCopyWith<$Res> {
  factory _$PronunciationFocusCopyWith(
          _PronunciationFocus value, $Res Function(_PronunciationFocus) _then) =
      __$PronunciationFocusCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<String> targetSounds,
      List<String> words,
      List<String> sentences,
      Map<String, String>? tips});
}

/// @nodoc
class __$PronunciationFocusCopyWithImpl<$Res>
    implements _$PronunciationFocusCopyWith<$Res> {
  __$PronunciationFocusCopyWithImpl(this._self, this._then);

  final _PronunciationFocus _self;
  final $Res Function(_PronunciationFocus) _then;

  /// Create a copy of PronunciationFocus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? targetSounds = null,
    Object? words = null,
    Object? sentences = null,
    Object? tips = freezed,
  }) {
    return _then(_PronunciationFocus(
      targetSounds: null == targetSounds
          ? _self._targetSounds
          : targetSounds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      words: null == words
          ? _self._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sentences: null == sentences
          ? _self._sentences
          : sentences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tips: freezed == tips
          ? _self._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

// dart format on
