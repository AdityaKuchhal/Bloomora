import '../services/supabase_service.dart';

/// The three pieces of auth behavior app_api_client.dart's 401 handling
/// needs, kept behind an interface so tests can fake them without a live
/// Supabase session. The concrete implementation deliberately does NOT
/// keep its own copy of the token (unlike the legacy lib/core/api/
/// api_client.dart, which mirrors it into flutter_secure_storage on every
/// sign-in) — it reads SupabaseService.auth.currentSession fresh on every
/// call, so there's exactly one source of truth for the token.
abstract class ApiAuthGateway {
  /// The current Supabase access token, or null if there's no session.
  String? get accessToken;

  /// Attempts one session refresh via the Supabase SDK. Returns whether a
  /// usable access token exists afterward.
  Future<bool> refreshSession();

  /// Called when a 401 survives a refresh-and-retry: clears the local
  /// session so route_guards.dart's own auth check redirects to /sign-in
  /// on the next navigation. This client deliberately does not do any
  /// navigation itself — it shouldn't know about routes.
  Future<void> handleUnrecoverableSession();
}

class SupabaseApiAuthGateway implements ApiAuthGateway {
  const SupabaseApiAuthGateway();

  @override
  String? get accessToken => SupabaseService.auth.currentSession?.accessToken;

  @override
  Future<bool> refreshSession() async {
    try {
      await SupabaseService.auth.refreshSession();
    } catch (_) {
      // Refresh failed (expired refresh token, offline, revoked session,
      // ...) — the caller checks accessToken below regardless of why.
    }
    return SupabaseService.auth.currentSession?.accessToken != null;
  }

  @override
  Future<void> handleUnrecoverableSession() async {
    // GoTrueClient.signOut()'s default scope is local: it removes the
    // local session and fires AuthChangeEvent.signedOut synchronously,
    // before it even attempts the best-effort remote sign-out call (which
    // itself swallows 401/403/404 — an already-invalid token is expected
    // here, not an error). authProvider picks up that event and
    // route_guards.dart's guard redirects on the next navigation, with no
    // extra wiring needed from this client.
    try {
      await SupabaseService.auth.signOut();
    } catch (_) {
      // Local session removal already happened synchronously inside
      // signOut() above; a failure here is the best-effort remote call
      // and isn't something this client can or should surface.
    }
  }
}
