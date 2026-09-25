import 'package:sentry_flutter/sentry_flutter.dart';

/// The actual Sentry SDK send call, behind a narrow interface — same
/// testability seam as AnalyticsBackend (see analytics_backend.dart):
/// Sentry's static API can't be meaningfully driven in a headless
/// `flutter test` without a real transport, so ErrorReporter is built
/// against this interface and tests inject a fake.
abstract class ErrorReporterBackend {
  Future<void> captureException(dynamic throwable, {dynamic stackTrace});
}

class SentryErrorReporterBackend implements ErrorReporterBackend {
  const SentryErrorReporterBackend();

  @override
  Future<void> captureException(dynamic throwable, {dynamic stackTrace}) async {
    await Sentry.captureException(throwable, stackTrace: stackTrace);
  }
}
