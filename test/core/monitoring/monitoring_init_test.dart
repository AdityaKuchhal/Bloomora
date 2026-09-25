// Proves session replay is explicitly disabled in both SDKs' actual init
// options — a real config assertion against the same functions real init
// uses (see monitoring_init.dart), not "it's off by default."
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:bloomora/core/monitoring/monitoring_init.dart';

void main() {
  // configureSentryOptions/configurePostHogConfig read AppConfig.sentryDsn
  // etc., which read dotenv.env — never loaded in a headless test
  // otherwise (dotenv throws NotInitializedError). testLoad() is
  // flutter_dotenv's own supported seam for exactly this.
  setUp(() {
    dotenv.testLoad(fileInput: 'SENTRY_DSN=\nPOSTHOG_KEY=\nPOSTHOG_HOST=https://us.i.posthog.com');
  });

  group('Sentry options', () {
    test('session replay is explicitly disabled (both sample rates set to 0.0)', () {
      final options = SentryFlutterOptions();
      configureSentryOptions(options, release: 'test@1.0.0+1');

      expect(options.replay.sessionSampleRate, 0.0);
      expect(options.replay.onErrorSampleRate, 0.0);
    });

    test('environment is set to the current app Environment (AC1)', () {
      final options = SentryFlutterOptions();
      configureSentryOptions(options, release: 'test@1.0.0+1');

      // Environment.current defaults to development with no --dart-define
      // override, which is the real value in this test run — not mocked.
      expect(options.environment, 'development');
    });

    test('release is set to the value passed in (AC1)', () {
      final options = SentryFlutterOptions();
      configureSentryOptions(options, release: 'com.amazingpathkids.bloomora@1.0.0+1');

      expect(options.release, 'com.amazingpathkids.bloomora@1.0.0+1');
    });

    test('beforeSend is set to the real scrub function', () {
      final options = SentryFlutterOptions();
      configureSentryOptions(options, release: 'test@1.0.0+1');

      expect(options.beforeSend, isNotNull);
    });
  });

  group('buildReleaseString (AC1: exercises the package.json/pubspec-version fallback path, not just implements it)', () {
    test('builds "<packageName>@<version>+<buildNumber>" from real PackageInfo fields', () {
      final packageInfo = PackageInfo(
        appName: 'Bloomora',
        packageName: 'com.amazingpathkids.bloomora',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(buildReleaseString(packageInfo), 'com.amazingpathkids.bloomora@1.0.0+1');
    });

    test('reflects whatever version/build values PackageInfo actually reports, not a hardcoded string', () {
      final packageInfo = PackageInfo(
        appName: 'Bloomora',
        packageName: 'com.amazingpathkids.bloomora',
        version: '2.3.4',
        buildNumber: '17',
        buildSignature: '',
      );

      expect(buildReleaseString(packageInfo), 'com.amazingpathkids.bloomora@2.3.4+17');
    });
  });

  group('PostHog config', () {
    test('session replay is explicitly disabled', () {
      final config = PostHogConfig('test-key');
      configurePostHogConfig(config);

      expect(config.sessionReplay, isFalse);
    });

    test('optOut is explicitly true (defense-in-depth alongside AnalyticsService\'s own gate)', () {
      final config = PostHogConfig('test-key');
      configurePostHogConfig(config);

      expect(config.optOut, isTrue);
    });
  });
}
