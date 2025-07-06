import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AsyncValue.data(null));

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );

      if (response.user == null) {
        throw Exception('サインアップに失敗しました');
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      print('AuthNotifier.signIn: Attempting to sign in with email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('AuthNotifier.signIn: Response user: ${response.user?.email}');
      print('AuthNotifier.signIn: Response session: ${response.session != null}');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('AuthNotifier.signIn: Error: $e');
      print('AuthNotifier.signIn: Stack trace: $st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthNotifier(supabase);
}); 