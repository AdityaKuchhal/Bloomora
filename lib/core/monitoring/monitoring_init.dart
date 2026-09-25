import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/app_config.dart';
import '../config/environment.dart';
import 'sentry_scrub.dart';

/// Called once at app startup, after config has loaded successfully.
/// Initializes Sentry and PostHog if their env vars are configured for
/// this environment; skips (not errors) whichever one isn't. Every SDK
/// call is wrapped in try/catch — a monitoring init failure must never
/// crash the app or block startup (FT-008 AC).
Future<void> initMonitoring() async {
  await _initSentry();
  await _initPostHog();
}

/// The actual options-building logic passed to `SentryFlutter.init`,
/// pulled out as its own function so a test can construct a bare
/// `SentryFlutterOptions()` and call this directly to assert on the
/// result (session replay disabled, environment/release/beforeSend set)
/// without needing Sentry's platform channels to exist — see
/// test/core/monitoring/monitoring_init_test.dart. This is the SAME
/// function real init uses, not a parallel reimplementation.
void configureSentryOptions(SentryFlutterOptions options, {required String release}) {
  options.dsn = AppConfig.sentryDsn;
  options.environment = Environment.current.name;
  options.release = release;
  // Explicitly disabled, not just left at default.
  options.replay.sessionSampleRate = 0.0;
  options.replay.onErrorSampleRate = 0.0;
  options.beforeSend = scrubSentryEvent;
}

/// Same pattern as [configureSentryOptions] — real config-building logic,
/// directly testable against a bare `PostHogConfig` without touching the
/// platform-channel-backed `Posthog()` singleton.
void configurePostHogConfig(PostHogConfig config) {
  config.host = AppConfig.posthogHost;
  // AnalyticsService itself defaults to disabled and gates every
  // capture/identify/reset call before ever reaching the SDK — this is
  // additional defense-in-depth at the native-SDK level in case something
  // outside AnalyticsService ever touches Posthog() directly. Explicitly
  // set, not left at whatever the SDK default happens to be.
  config.optOut = true;
  // Explicitly disabled, not just left at default — same standard as
  // Sentry's replay options above.
  config.sessionReplay = false;
}

/// Release format: `<package>@<version>+<build>`, e.g.
/// `com.amazingpathkids.bloomora@1.0.0+1` — Sentry's conventional
/// "release" format. Not a literal env var — Flutter doesn't have one for
/// this; package_info_plus reads it from the platform build artifacts
/// (pubspec.yaml's `version:` field), which is what the ticket asked to
/// check rather than assume. Pulled out as its own function so a test can
/// drive it with `PackageInfo.setMockInitialValues` (package_info_plus's
/// own supported test seam) instead of needing a real platform channel.
String buildReleaseString(PackageInfo packageInfo) {
  return '${packageInfo.packageName}@${packageInfo.version}+${packageInfo.buildNumber}';
}

Future<void> _initSentry() async {
  if (AppConfig.sentryDsn.isEmpty) return;
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final release = buildReleaseString(packageInfo);

    await SentryFlutter.init((options) => configureSentryOptions(options, release: release));
  } catch (_) {
    // Silent — see initMonitoring's doc comment.
  }
}

Future<void> _initPostHog() async {
  if (AppConfig.posthogKey.isEmpty) return;
  try {
    final config = PostHogConfig(AppConfig.posthogKey);
    configurePostHogConfig(config);
    await Posthog().setup(config);
  } catch (_) {
    // Silent — see initMonitoring's doc comment.
  }
}
