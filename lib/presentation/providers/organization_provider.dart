import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sozo_app/data/models/user_role_model.dart';
import 'package:sozo_app/presentation/providers/auth_provider.dart';

// Supabaseプロバイダー
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

// 現在のユーザーのロール情報を取得
final currentUserRoleProvider = FutureProvider<UserOrganizationRole?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return null;
  
  try {
    final response = await supabase
        .from('user_organization_roles')
        .select('*, organizations(*)')
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (response == null) return null;
    
    return UserOrganizationRole.fromJson(response);
  } catch (e) {
    print('Error fetching user role: $e');
    return null;
  }
});

// 組織のユーザー一覧を取得
final organizationUsersProvider = FutureProvider<List<ExtendedUserProfile>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userRole = await ref.watch(currentUserRoleProvider.future);
  
  if (userRole == null) return [];
  
  try {
    final response = await supabase
        .from('get_organization_learning_stats')
        .select()
        .eq('p_organization_id', userRole.organizationId);
    
    return response.map<ExtendedUserProfile>((data) => ExtendedUserProfile(
      id: data['user_id'],
      email: data['email'],
      username: data['username'],
      totalXp: data['total_xp'],
      currentLevel: data['current_level'],
      streakCount: data['streak_count'],
    )).toList();
  } catch (e) {
    print('Error fetching organization users: $e');
    return [];
  }
});

// 組織の学習進捗データを取得
final organizationLearningProgressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userRole = await ref.watch(currentUserRoleProvider.future);
  
  if (userRole == null) return {};
  
  try {
    final stats = await supabase
        .rpc('get_organization_learning_stats', params: {
          'p_organization_id': userRole.organizationId
        });
    
    if (stats is List && stats.isNotEmpty) {
      final users = stats.cast<Map<String, dynamic>>();
      
      // 統計情報を計算
      final totalUsers = users.length;
      final activeUsers = users.where((u) => (u['total_minutes'] ?? 0) > 0).length;
      final averageLevel = users.isNotEmpty 
          ? users.fold<num>(0, (sum, u) => sum + (u['current_level'] ?? 1)) / users.length
          : 0.0;
      
      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'averageLevel': averageLevel,
        'users': users,
      };
    }
    
    return {
      'totalUsers': 0,
      'activeUsers': 0,
      'averageLevel': 0.0,
      'users': <Map<String, dynamic>>[],
    };
  } catch (e) {
    print('Error fetching organization progress: $e');
    return {
      'totalUsers': 0,
      'activeUsers': 0,
      'averageLevel': 0.0,
      'users': <Map<String, dynamic>>[],
    };
  }
});

// 組織招待用プロバイダー
final organizationInvitationProvider = Provider.family<Future<bool>, Map<String, String>>((ref, params) async {
  final supabase = ref.watch(supabaseProvider);
  final userRole = await ref.watch(currentUserRoleProvider.future);
  
  if (userRole == null || userRole.role != UserRole.admin) {
    throw Exception('管理者権限が必要です');
  }
  
  try {
    await supabase.from('organization_invitations').insert({
      'email': params['email'],
      'organization_id': userRole.organizationId,
      'role': params['role'],
      'invited_by': userRole.userId,
    });
    
    return true;
  } catch (e) {
    print('Error sending invitation: $e');
    return false;
  }
}); 