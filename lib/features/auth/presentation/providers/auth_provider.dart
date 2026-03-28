import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/auth_service.dart';
import '../../../../core/services/supabase_service.dart';

// ── Auth Status ──────────────────────────────────────────────────────────────

enum AuthStatus { unknown, authenticated, unauthenticated }

// ── App Auth State (named AppAuthState to avoid collision with supabase's AuthState) ──

class AppAuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;

  const AppAuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  AppAuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AppAuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(const AppAuthState()) {
    _init();
  }

  void _init() {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authSubscription = SupabaseService.authStateChanges.listen((event) {
      final user = event.session?.user;
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          clearUser: true,
          clearError: true,
        );
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.signIn(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyAuthError(e));
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await AuthService.signOut();
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  String _friendlyAuthError(AuthException e) {
    if (e.message.contains('Invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (e.message.contains('Email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (e.message.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    return e.message;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authProvider).user,
);

final authReadyProvider = Provider<bool>(
  (ref) => !ref.watch(authProvider).isUnknown,
);