import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/api/api_client.dart';

class AuthService {
  AuthService._();

  // Check if an email is already registered.
  // Uses Supabase's OTP trick: if sign-in with OTP succeeds, the user exists.
  // We do a lightweight fetch against a custom RPC instead.
  static Future<bool> emailExists(String email) async {
    try {
      final response = await SupabaseService.client
          .from('parents')
          .select('id')
          .eq('email', email.toLowerCase().trim())
          .maybeSingle();
      return response != null;
    } catch (_) {
      return false;
    }
  }

  // Sign up with email + password, then insert parent profile row.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await SupabaseService.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );

    // Parent row is created automatically via DB trigger (handle_new_user).
    // Only store the token if a session is immediately available
    // (email confirmation disabled). If confirmation is required,
    // the session arrives later via the auth stream.
    if (response.session != null) {
      await ApiClient.setToken(response.session!.accessToken);
    }

    return response;
  }

  // Sign in with email + password.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await SupabaseService.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final session = response.session;
    if (session != null) {
      await ApiClient.setToken(session.accessToken);
    }

    return response;
  }

  // Sign out — clears Supabase session and local token.
  static Future<void> signOut() async {
    await SupabaseService.auth.signOut();
    await ApiClient.clearToken();
  }

  // Send password reset email.
  static Future<void> resetPassword(String email) async {
    await SupabaseService.auth.resetPasswordForEmail(email.trim());
  }

  // Refresh token on startup if session exists.
  static Future<void> refreshSessionIfNeeded() async {
    final session = SupabaseService.auth.currentSession;
    if (session != null && session.isExpired) {
      await SupabaseService.auth.refreshSession();
    }
    final accessToken = SupabaseService.auth.currentSession?.accessToken;
    if (accessToken != null) {
      await ApiClient.setToken(accessToken);
    }
  }

  static User? get currentUser => SupabaseService.currentUser;
  static bool get isAuthenticated => SupabaseService.isAuthenticated;
}