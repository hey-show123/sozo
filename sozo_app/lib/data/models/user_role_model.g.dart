// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Organization _$OrganizationFromJson(Map<String, dynamic> json) =>
    _Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$OrganizationToJson(_Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_UserOrganizationRole _$UserOrganizationRoleFromJson(
        Map<String, dynamic> json) =>
    _UserOrganizationRole(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      organizationId: json['organization_id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      organization: json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserOrganizationRoleToJson(
        _UserOrganizationRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'organization_id': instance.organizationId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'organization': instance.organization,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.learner: 'learner',
  UserRole.viewer: 'viewer',
  UserRole.admin: 'admin',
  UserRole.superAdmin: 'super_admin',
};

_ExtendedUserProfile _$ExtendedUserProfileFromJson(Map<String, dynamic> json) =>
    _ExtendedUserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      totalXp: (json['totalXp'] as num?)?.toInt(),
      currentLevel: (json['currentLevel'] as num?)?.toInt(),
      streakCount: (json['streakCount'] as num?)?.toInt(),
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$ExtendedUserProfileToJson(
        _ExtendedUserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'totalXp': instance.totalXp,
      'currentLevel': instance.currentLevel,
      'streakCount': instance.streakCount,
      'avatarUrl': instance.avatarUrl,
      'role': _$UserRoleEnumMap[instance.role],
    };
