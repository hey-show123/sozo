import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

// ユーザープロフィール情報
class UserProfile {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {String? email}) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String? ?? email,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // 表示名を取得（優先順位: displayName > username > emailの@前 > 'ゲスト'）
  String get displayNameOrDefault {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (username != null && username!.isNotEmpty) return username!;
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'ゲスト';
  }

  // アバターの頭文字を取得
  String get initials {
    final name = displayNameOrDefault;
    if (name.isEmpty) return '?';
    
    // 日本語の場合は最初の文字をそのまま返す
    if (RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(name[0])) {
      return name[0];
    }
    
    // 英語の場合は大文字にして返す
    return name[0].toUpperCase();
  }
}

// ユーザープロフィールプロバイダー
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) {
    print('UserProfileProvider: No user logged in');
    return null;
  }
  
  try {
    print('UserProfileProvider: Loading profile for user ${user.id}');
    
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    
    print('UserProfileProvider: Profile loaded successfully');
    return UserProfile.fromJson(response, email: user.email);
  } catch (e) {
    print('UserProfileProvider: Error loading profile: $e');
    // エラーが発生した場合でも基本的な情報を返す
    return UserProfile(
      id: user.id,
      email: user.email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}); 