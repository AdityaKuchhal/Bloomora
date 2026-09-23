import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'environment.dart';

class AppConfig {
  AppConfig._();

  /// Values that mark a `.env.<environment>` entry as an unfilled
  /// placeholder (staging/production before real infra exists). Treated
  /// the same as "missing" by [missingRequiredConfigKeys].
  static bool _isPlaceholder(String value) =>
      value.isEmpty || value.contains('REPLACE_WITH_');

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get googleIosClientId =>
      const String.fromEnvironment(
        'GOOGLE_IOS_CLIENT_ID',
        defaultValue: '913713027107-n9pnb1j6jr5a58bfc4ubsmpa774tio66.apps.googleusercontent.com',
      );

  static String get googleWebClientId =>
      const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '913713027107-7tngclt6mq59k3pn0pgu3ui9i94dtoln.apps.googleusercontent.com',
      );

  static Environment get environment => Environment.current;
  static bool get isDevelopment => environment == Environment.development;
  static bool get isProduction => environment == Environment.production;

  /// Public config vars that must be present and non-placeholder for the
  /// app to function. Checked once at startup — see [main.dart] — so a
  /// missing/misconfigured environment fails fast with a readable error
  /// instead of crashing or silently connecting to the wrong place.
  static Map<String, String> get _requiredConfig => {
        'API_BASE_URL': apiBaseUrl,
        'SUPABASE_URL': supabaseUrl,
        'SUPABASE_ANON_KEY': supabaseAnonKey,
      };

  /// Names of required config keys that are missing or still a
  /// REPLACE_WITH_* placeholder. Empty when config is valid.
  static List<String> get missingRequiredConfigKeys => _requiredConfig.entries
      .where((e) => _isPlaceholder(e.value))
      .map((e) => e.key)
      .toList();
}
