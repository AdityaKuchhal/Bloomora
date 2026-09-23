import 'package:flutter/material.dart';

import 'environment.dart';

/// Shown instead of [BloomoraApp] when required public config
/// (API_BASE_URL / SUPABASE_URL / SUPABASE_ANON_KEY) is missing or still a
/// REPLACE_WITH_* placeholder for the selected [Environment]. Replaces an
/// uncaught crash / Flutter red screen with a readable explanation — see
/// docs/audit-findings.md FT-001 AC5.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({
    super.key,
    required this.environment,
    required this.missingKeys,
  });

  final Environment environment;
  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Configuration Error',
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings_suggest_outlined, color: Colors.amber, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration Error',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The app could not start because required configuration for '
                    'the "${environment.name}" environment is missing or still a '
                    'placeholder value.',
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Missing or placeholder keys:',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...missingKeys.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $k',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fix: fill in real values in ${environment.envFileName} '
                    '(copy from ${environment.envFileName}.example if it doesn\'t exist yet). '
                    'See the "Development Setup" section in README.md.',
                    style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
