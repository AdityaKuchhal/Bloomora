/// Which backing environment this build targets.
///
/// Selected at build/run time via `--dart-define=APP_ENV=development|staging|production`.
/// Defaults to [development] when no flag is passed, so `flutter run` with
/// no arguments keeps working unchanged.
enum Environment {
  development,
  staging,
  production;

  /// The SOURCE file `scripts/select_env.sh` copies to `.env` before
  /// build/run — not itself a bundled asset. Only `.env` is ever declared
  /// under `flutter.assets` in pubspec.yaml, so a build only ever contains
  /// one environment's values, never all three. See README.md
  /// "Development Setup".
  String get envFileName => '.env.$name';

  static Environment get current {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => Environment.development,
    );
  }
}
