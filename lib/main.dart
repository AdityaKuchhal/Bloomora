import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/api/api_client.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

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
