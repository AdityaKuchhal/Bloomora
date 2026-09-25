import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/api/api_client.dart';
import 'core/config/app_config.dart';
import 'core/config/config_error_screen.dart';
import 'core/config/environment.dart';
import 'core/monitoring/monitoring_init.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = Environment.current;

  // Only .env is ever a declared Flutter asset (see pubspec.yaml) — never
  // .env.development/.env.staging/.env.production directly, or every build
  // would bundle every environment's values. scripts/select_env.sh copies
  // the target environment's file to .env before build/run, matching the
  // --dart-define=APP_ENV=... used to select [environment] above. A
  // missing .env throws here — that's still a config error, caught below
  // rather than left as an uncaught crash.
  List<String> missingConfigKeys;
  try {
    await dotenv.load(fileName: '.env');
    missingConfigKeys = AppConfig.missingRequiredConfigKeys;

    // Safety net: catches a stale/forgotten `scripts/select_env.sh` run —
    // e.g. --dart-define=APP_ENV=production but .env still holds whatever
    // was last copied in (often development). Without this check the app
    // would silently run production code paths against dev data instead of
    // failing fast.
    final loadedAppEnv = dotenv.env['APP_ENV'];
    if (loadedAppEnv != environment.name) {
      missingConfigKeys = [
        'APP_ENV mismatch: expected "${environment.name}" but .env contains '
            '"${loadedAppEnv ?? '(missing)'}". Run: scripts/select_env.sh ${environment.name}',
      ];
    }
  } catch (_) {
    missingConfigKeys = const ['API_BASE_URL', 'SUPABASE_URL', 'SUPABASE_ANON_KEY'];
  }

  if (missingConfigKeys.isNotEmpty) {
    runApp(ConfigErrorApp(environment: environment, missingKeys: missingConfigKeys));
    return;
  }

  // Monitoring (Sentry + PostHog) — before Supabase, so crashes during
  // Supabase/Hive/ApiClient init below are also captured. Silent on
  // failure by design (see initMonitoring's doc comment) — never blocks
  // startup.
  await initMonitoring();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Refresh session token if user was previously logged in
  await AuthService.refreshSessionIfNeeded();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize API client (loads stored auth token)
  await ApiClient.initialize();

  runApp(
    const ProviderScope(
      child: BloomoraApp(),
    ),
  );
}

class BloomoraApp extends ConsumerWidget {
  const BloomoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // CHECK 3: initialize keepAlive provider on startup so SharedPreferences
    // persistence loads before any screen renders.
    ref.read(themeNotifierProvider);
    // CHECK 2: wire active color scheme to MaterialApp theme.
    final scheme = ref.watch(activeColorSchemeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(scheme),
      routerConfig: router,
    );
  }
}
