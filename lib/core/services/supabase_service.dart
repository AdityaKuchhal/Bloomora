import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    // TODO(FT-015): /reset-password (lib/features/auth/presentation/pages/
    // reset_password_page.dart) and its route/guard/token-exchange logic
    // are correct, but nothing can currently hand the app that URL — there's
    // no custom URL scheme / universal link / associated domain registered
    // (Info.plist, AndroidManifest.xml), and no Supabase "redirect URL" is
    // configured here or in the Supabase dashboard. FT-015 owns wiring an
    // actual deep-link path in, likely via a `redirectTo:` param here plus
    // native scheme/domain registration.
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
