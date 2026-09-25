import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/monitoring/error_reporter.dart';
import 'package:bloomora/core/monitoring/error_reporter_backend.dart';

class _RecordingBackend implements ErrorReporterBackend {
  final List<dynamic> captured = [];
  Object? throwOnCapture;

  @override
  Future<void> captureException(dynamic throwable, {dynamic stackTrace}) async {
    if (throwOnCapture != null) throw throwOnCapture!;
    captured.add(throwable);
  }
}

void main() {
  test('captureException delegates to the backend', () async {
    final backend = _RecordingBackend();
    final reporter = ErrorReporter(backend: backend);

    final error = Exception('a real Flutter exception for this test run');
    await reporter.captureException(error, stackTrace: StackTrace.current);

    expect(backend.captured, [error]);
  });

  test('a backend failure during captureException never propagates (monitoring must be silent)', () async {
    final backend = _RecordingBackend()..throwOnCapture = Exception('Sentry transport down');
    final reporter = ErrorReporter(backend: backend);

    await expectLater(
      reporter.captureException(Exception('original app error')),
      completes,
    );
  });
}
