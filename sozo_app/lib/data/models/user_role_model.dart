import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_role_model.freezed.dart';
part 'user_role_model.g.dart';

enum UserRole {
  @JsonValue('learner')
  learner,
  @JsonValue('viewer')
  viewer,
  @JsonValue('admin')
  admin,
  @JsonValue('super_admin')
  superAdmin,
}

@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

@freezed
abstract class UserOrganizationRole with _$UserOrganizationRole {
  const factory UserOrganizationRole({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'organization_id') required String organizationId,
    required UserRole role,
    Organization? organization,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserOrganizationRole;

  factory UserOrganizationRole.fromJson(Map<String, dynamic> json) =>
      _$UserOrganizationRoleFromJson(json);
}

@freezed
abstract class ExtendedUserProfile with _$ExtendedUserProfile {
  const factory ExtendedUserProfile({
    required String id,
    required String email,
    String? username,
    int? totalXp,
    int? currentLevel,
    int? streakCount,
    String? avatarUrl,
    UserRole? role,
  }) = _ExtendedUserProfile;

  factory ExtendedUserProfile.fromJson(Map<String, dynamic> json) =>
      _$ExtendedUserProfileFromJson(json);
} 