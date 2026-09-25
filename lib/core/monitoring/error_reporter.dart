import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_reporter_backend.dart';

/// Wraps all Sentry calls (Frontend Spec §8: "No ... Sentry calls
/// directly in widgets; route through ... ErrorReporter"). Unlike
/// AnalyticsService, error monitoring is NOT consent-gated — the docs
/// frame Sentry as always-on with strict scrubbing (via
/// sentry_scrub.dart's beforeSend hook, configured at SentryFlutter.init
/// time in main.dart), distinct from behavioral analytics.
///
/// Monitoring failures must never crash the app or block a user flow —
/// every call here is wrapped so a Sentry send failure can't propagate.
class ErrorReporter {
  ErrorReporter({ErrorReporterBackend? backend})
      : _backend = backend ?? const SentryErrorReporterBackend();

  final ErrorReporterBackend _backend;

  Future<void> captureException(dynamic throwable, {dynamic stackTrace}) async {
    try {
      await _backend.captureException(throwable, stackTrace: stackTrace);
    } catch (_) {
      // Silent — a monitoring failure must never surface to the user or
      // crash the app.
    }
  }
}

/// App-wide singleton — overridden in tests with a fake
/// ErrorReporterBackend (see test/core/monitoring/error_reporter_test.dart).
final errorReporterProvider = Provider<ErrorReporter>((ref) {
  return ErrorReporter();
});
