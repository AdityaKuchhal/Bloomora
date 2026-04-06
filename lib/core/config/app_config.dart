import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://bloomora-api.up.railway.app/api/v1';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

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

  static String get openAiApiKey =>
      dotenv.env['OPENAI_API_KEY'] ?? '';

  static String get appEnv =>
      dotenv.env['APP_ENV'] ?? 'development';

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}