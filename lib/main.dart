import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
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

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
