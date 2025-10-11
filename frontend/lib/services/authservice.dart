import 'package:supabase_flutter/supabase_flutter.dart';

class Authservice {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword({
    required String Password,
    required String Email,
    required String Username,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        password: Password,
        email: Email,
      );
      await _supabase.auth.updateUser(
        UserAttributes(data: {"username": Username}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      await _supabase.auth.updateUser(
        UserAttributes(data: {"username": username}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> changePasswordWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    _supabase.auth.signOut();
  }

  Map<String, dynamic>? getUser() {
    final sessionUser = _supabase.auth.currentSession;
    final User = sessionUser?.user;
    final Username = User?.userMetadata?['username'];
    return {"email": User?.email, "username": Username};
  }
}
