// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_role_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Organization {
  String get id;
  String get name;
  String? get description;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<Organization> get copyWith =>
      _$OrganizationCopyWithImpl<Organization>(
          this as Organization, _$identity);

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Organization &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, createdAt, updatedAt);

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $OrganizationCopyWith<$Res> {
  factory $OrganizationCopyWith(
          Organization value, $Res Function(Organization) _then) =
      _$OrganizationCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$OrganizationCopyWithImpl<$Res> implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._self, this._then);

  final Organization _self;
  final $Res Function(Organization) _then;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _Organization implements Organization {
  const _Organization(
      {required this.id,
      required this.name,
      this.description,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OrganizationCopyWith<_Organization> get copyWith =>
      __$OrganizationCopyWithImpl<_Organization>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OrganizationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Organization &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, createdAt, updatedAt);

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$OrganizationCopyWith<$Res>
    implements $OrganizationCopyWith<$Res> {
  factory _$OrganizationCopyWith(
          _Organization value, $Res Function(_Organization) _then) =
      __$OrganizationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$OrganizationCopyWithImpl<$Res>
    implements _$OrganizationCopyWith<$Res> {
  __$OrganizationCopyWithImpl(this._self, this._then);

  final _Organization _self;
  final $Res Function(_Organization) _then;

  /// Create a copy of Organization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Organization(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
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
mixin _$UserOrganizationRole {
  String get id;
  @JsonKey(name: 'user_id')
  String get userId;
  @JsonKey(name: 'organization_id')
  String get organizationId;
  UserRole get role;
  Organization? get organization;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserOrganizationRoleCopyWith<UserOrganizationRole> get copyWith =>
      _$UserOrganizationRoleCopyWithImpl<UserOrganizationRole>(
          this as UserOrganizationRole, _$identity);

  /// Serializes this UserOrganizationRole to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserOrganizationRole &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, organizationId, role,
      organization, createdAt, updatedAt);

  @override
  String toString() {
    return 'UserOrganizationRole(id: $id, userId: $userId, organizationId: $organizationId, role: $role, organization: $organization, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $UserOrganizationRoleCopyWith<$Res> {
  factory $UserOrganizationRoleCopyWith(UserOrganizationRole value,
          $Res Function(UserOrganizationRole) _then) =
      _$UserOrganizationRoleCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'organization_id') String organizationId,
      UserRole role,
      Organization? organization,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});

  $OrganizationCopyWith<$Res>? get organization;
}

/// @nodoc
class _$UserOrganizationRoleCopyWithImpl<$Res>
    implements $UserOrganizationRoleCopyWith<$Res> {
  _$UserOrganizationRoleCopyWithImpl(this._self, this._then);

  final UserOrganizationRole _self;
  final $Res Function(UserOrganizationRole) _then;

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? organizationId = null,
    Object? role = null,
    Object? organization = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      organizationId: null == organizationId
          ? _self.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      organization: freezed == organization
          ? _self.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as Organization?,
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

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res>? get organization {
    if (_self.organization == null) {
      return null;
    }

    return $OrganizationCopyWith<$Res>(_self.organization!, (value) {
      return _then(_self.copyWith(organization: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _UserOrganizationRole implements UserOrganizationRole {
  const _UserOrganizationRole(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'organization_id') required this.organizationId,
      required this.role,
      this.organization,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserOrganizationRole.fromJson(Map<String, dynamic> json) =>
      _$UserOrganizationRoleFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'organization_id')
  final String organizationId;
  @override
  final UserRole role;
  @override
  final Organization? organization;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserOrganizationRoleCopyWith<_UserOrganizationRole> get copyWith =>
      __$UserOrganizationRoleCopyWithImpl<_UserOrganizationRole>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserOrganizationRoleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserOrganizationRole &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.organization, organization) ||
                other.organization == organization) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, organizationId, role,
      organization, createdAt, updatedAt);

  @override
  String toString() {
    return 'UserOrganizationRole(id: $id, userId: $userId, organizationId: $organizationId, role: $role, organization: $organization, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$UserOrganizationRoleCopyWith<$Res>
    implements $UserOrganizationRoleCopyWith<$Res> {
  factory _$UserOrganizationRoleCopyWith(_UserOrganizationRole value,
          $Res Function(_UserOrganizationRole) _then) =
      __$UserOrganizationRoleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'organization_id') String organizationId,
      UserRole role,
      Organization? organization,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});

  @override
  $OrganizationCopyWith<$Res>? get organization;
}

/// @nodoc
class __$UserOrganizationRoleCopyWithImpl<$Res>
    implements _$UserOrganizationRoleCopyWith<$Res> {
  __$UserOrganizationRoleCopyWithImpl(this._self, this._then);

  final _UserOrganizationRole _self;
  final $Res Function(_UserOrganizationRole) _then;

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? organizationId = null,
    Object? role = null,
    Object? organization = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_UserOrganizationRole(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      organizationId: null == organizationId
          ? _self.organizationId
          : organizationId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      organization: freezed == organization
          ? _self.organization
          : organization // ignore: cast_nullable_to_non_nullable
              as Organization?,
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

  /// Create a copy of UserOrganizationRole
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationCopyWith<$Res>? get organization {
    if (_self.organization == null) {
      return null;
    }

    return $OrganizationCopyWith<$Res>(_self.organization!, (value) {
      return _then(_self.copyWith(organization: value));
    });
  }
}

/// @nodoc
mixin _$ExtendedUserProfile {
  String get id;
  String get email;
  String? get username;
  int? get totalXp;
  int? get currentLevel;
  int? get streakCount;
  String? get avatarUrl;
  UserRole? get role;

  /// Create a copy of ExtendedUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExtendedUserProfileCopyWith<ExtendedUserProfile> get copyWith =>
      _$ExtendedUserProfileCopyWithImpl<ExtendedUserProfile>(
          this as ExtendedUserProfile, _$identity);

  /// Serializes this ExtendedUserProfile to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExtendedUserProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, username, totalXp,
      currentLevel, streakCount, avatarUrl, role);

  @override
  String toString() {
    return 'ExtendedUserProfile(id: $id, email: $email, username: $username, totalXp: $totalXp, currentLevel: $currentLevel, streakCount: $streakCount, avatarUrl: $avatarUrl, role: $role)';
  }
}

/// @nodoc
abstract mixin class $ExtendedUserProfileCopyWith<$Res> {
  factory $ExtendedUserProfileCopyWith(
          ExtendedUserProfile value, $Res Function(ExtendedUserProfile) _then) =
      _$ExtendedUserProfileCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String email,
      String? username,
      int? totalXp,
      int? currentLevel,
      int? streakCount,
      String? avatarUrl,
      UserRole? role});
}

/// @nodoc
class _$ExtendedUserProfileCopyWithImpl<$Res>
    implements $ExtendedUserProfileCopyWith<$Res> {
  _$ExtendedUserProfileCopyWithImpl(this._self, this._then);

  final ExtendedUserProfile _self;
  final $Res Function(ExtendedUserProfile) _then;

  /// Create a copy of ExtendedUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? totalXp = freezed,
    Object? currentLevel = freezed,
    Object? streakCount = freezed,
    Object? avatarUrl = freezed,
    Object? role = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      totalXp: freezed == totalXp
          ? _self.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int?,
      currentLevel: freezed == currentLevel
          ? _self.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      streakCount: freezed == streakCount
          ? _self.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ExtendedUserProfile implements ExtendedUserProfile {
  const _ExtendedUserProfile(
      {required this.id,
      required this.email,
      this.username,
      this.totalXp,
      this.currentLevel,
      this.streakCount,
      this.avatarUrl,
      this.role});
  factory _ExtendedUserProfile.fromJson(Map<String, dynamic> json) =>
      _$ExtendedUserProfileFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? username;
  @override
  final int? totalXp;
  @override
  final int? currentLevel;
  @override
  final int? streakCount;
  @override
  final String? avatarUrl;
  @override
  final UserRole? role;

  /// Create a copy of ExtendedUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExtendedUserProfileCopyWith<_ExtendedUserProfile> get copyWith =>
      __$ExtendedUserProfileCopyWithImpl<_ExtendedUserProfile>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExtendedUserProfileToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExtendedUserProfile &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.totalXp, totalXp) || other.totalXp == totalXp) &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.streakCount, streakCount) ||
                other.streakCount == streakCount) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, email, username, totalXp,
      currentLevel, streakCount, avatarUrl, role);

  @override
  String toString() {
    return 'ExtendedUserProfile(id: $id, email: $email, username: $username, totalXp: $totalXp, currentLevel: $currentLevel, streakCount: $streakCount, avatarUrl: $avatarUrl, role: $role)';
  }
}

/// @nodoc
abstract mixin class _$ExtendedUserProfileCopyWith<$Res>
    implements $ExtendedUserProfileCopyWith<$Res> {
  factory _$ExtendedUserProfileCopyWith(_ExtendedUserProfile value,
          $Res Function(_ExtendedUserProfile) _then) =
      __$ExtendedUserProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? username,
      int? totalXp,
      int? currentLevel,
      int? streakCount,
      String? avatarUrl,
      UserRole? role});
}

/// @nodoc
class __$ExtendedUserProfileCopyWithImpl<$Res>
    implements _$ExtendedUserProfileCopyWith<$Res> {
  __$ExtendedUserProfileCopyWithImpl(this._self, this._then);

  final _ExtendedUserProfile _self;
  final $Res Function(_ExtendedUserProfile) _then;

  /// Create a copy of ExtendedUserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? username = freezed,
    Object? totalXp = freezed,
    Object? currentLevel = freezed,
    Object? streakCount = freezed,
    Object? avatarUrl = freezed,
    Object? role = freezed,
  }) {
    return _then(_ExtendedUserProfile(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      username: freezed == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      totalXp: freezed == totalXp
          ? _self.totalXp
          : totalXp // ignore: cast_nullable_to_non_nullable
              as int?,
      currentLevel: freezed == currentLevel
          ? _self.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      streakCount: freezed == streakCount
          ? _self.streakCount
          : streakCount // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole?,
    ));
  }
}

// dart format on
