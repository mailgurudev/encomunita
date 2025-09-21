import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';

/// Service for handling user authentication and profile management
class UserService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Sign up a new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Disable email confirmation for development
      );


      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in an existing user
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Create or update user profile
  Future<UserProfile> upsertProfile({
    required String fullName,
    required String address,
    required String communityName,
    String? phoneNumber,
  }) async {
    try {
      // Try multiple ways to get the current user
      var user = _supabase.auth.currentUser;

      // If no user, try to refresh the session
      if (user == null) {
        final session = await _supabase.auth.refreshSession();
        user = session.user;
      }

      // If still no user, try getting from session
      if (user == null) {
        final currentSession = _supabase.auth.currentSession;
        user = currentSession?.user;
      }

      if (user == null) {
        throw Exception('No authenticated user found - session may have expired');
      }

      final userId = user.id;

      final profileData = {
        'user_id': userId,
        'full_name': fullName,
        'address': address,
        'community_name': communityName,
        'phone_number': phoneNumber,
      };

      final response = await _supabase
          .from(SupabaseConfig.userProfilesTable)
          .upsert(profileData)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user's profile
  Future<UserProfile?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      final userId = user.id;

      final response = await _supabase
          .from(SupabaseConfig.userProfilesTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current authentication state
  Session? getCurrentSession() {
    return SupabaseConfig.currentSession;
  }

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// Provider for current authentication state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final userService = ref.read(userServiceProvider);
  return userService.authStateChanges;
});

/// Provider for current user profile
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userService = ref.read(userServiceProvider);

  // Watch auth state to refresh when user signs in/out
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) async {
      if (state.session != null) {
        return await userService.getCurrentProfile();
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});