import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as AppUser;
import '../utils/supabase_config.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Get current user
  static AppUser.User? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return AppUser.User(
      id: user.id,
      email: user.email ?? '',
      firstName: user.userMetadata?['first_name'],
      lastName: user.userMetadata?['last_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
      role: user.userMetadata?['role'] ?? 'user',
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null
          ? DateTime.parse(user.updatedAt!)
          : DateTime.parse(user.createdAt),
    );
  }

  // Sign up with email and password
  static Future<AppUser.User?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'user',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName, 'role': role},
      );

      if (response.user != null) {
        // Create user profile in database
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return AppUser.User(
          id: response.user!.id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: role,
          createdAt: DateTime.parse(response.user!.createdAt),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Failed to sign up: ${e.toString()}');
    }
    return null;
  }

  // Sign in with email and password
  static Future<AppUser.User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user profile from database
        final userProfile = await _client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        return AppUser.User.fromJson(userProfile);
      }
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Failed to sign in: ${e.toString()}');
    }
    return null;
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Update user profile
  static Future<AppUser.User?> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('users').update(updates).eq('id', user.id);

      // Update auth metadata
      await _client.auth.updateUser(
        UserAttributes(
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'avatar_url': avatarUrl,
          },
        ),
      );

      // Get updated user profile
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser.User.fromJson(userProfile);
    } catch (e) {
      print('Update profile error: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Get auth state stream
  static Stream<AuthState> get authStateStream =>
      _client.auth.onAuthStateChange;

  // Check if user is signed in
  static bool get isSignedIn => _client.auth.currentUser != null;
}
