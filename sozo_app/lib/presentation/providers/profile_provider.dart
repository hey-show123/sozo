import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// プロフィールモデル
class UserProfile {
  final String id;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final int currentLevel;
  final int totalXp;
  final int streakCount;

  UserProfile({
    required this.id,
    this.username,
    this.displayName,
    this.avatarUrl,
    required this.currentLevel,
    required this.totalXp,
    required this.streakCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      currentLevel: json['current_level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      streakCount: json['streak_count'] ?? 0,
    );
  }

  // 表示名を取得（display_name > username > email の優先順位）
  String getDisplayName(String? email) {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (username != null && username!.isNotEmpty) {
      return username!;
    }
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'ゲスト';
  }

  // 次のレベルまでの必要XP
  int get xpToNextLevel {
    // レベルアップに必要なXPは、レベル × 100
    return (currentLevel + 1) * 100;
  }

  // 現在のレベル内での進捗率（0.0 ~ 1.0）
  double get levelProgress {
    final currentLevelXp = currentLevel * 100;
    final nextLevelXp = xpToNextLevel;
    final progressXp = totalXp - currentLevelXp;
    final neededXp = nextLevelXp - currentLevelXp;
    
    if (neededXp <= 0) return 0.0;
    return (progressXp / neededXp).clamp(0.0, 1.0);
  }

  // 現在のレベル内でのXP
  int get currentLevelXp {
    return totalXp - (currentLevel * 100);
  }

  // 次のレベルまでの残りXP
  int get remainingXpToNextLevel {
    return xpToNextLevel - totalXp;
  }
}

// プロフィールプロバイダー
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return null;
  
  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return UserProfile.fromJson(response);
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
});

// プロフィール更新用のNotifier
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;
  
  ProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }
  
  Future<void> loadProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      
      if (userId == null) {
        state = const AsyncValue.data(null);
        return;
      }
      
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      state = AsyncValue.data(UserProfile.fromJson(response));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) return;
    
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (displayName != null) {
        updates['display_name'] = displayName;
      }
      
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      
      await supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      
      // プロフィールを再読み込み
      await loadProfile();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}

// プロフィール管理用のプロバイダー
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return ProfileNotifier(ref);
}); 