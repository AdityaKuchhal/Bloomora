import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/monitoring/analytics_backend.dart';
import 'package:bloomora/core/monitoring/analytics_event.dart';
import 'package:bloomora/core/monitoring/analytics_service.dart';

class _RecordingBackend implements AnalyticsBackend {
  final List<(String, Map<String, Object?>)> captured = [];
  final List<String> identified = [];
  int resetCount = 0;
  Object? throwOnCapture;

  @override
  Future<void> capture(String event, Map<String, Object?> properties) async {
    if (throwOnCapture != null) throw throwOnCapture!;
    captured.add((event, properties));
  }

  @override
  Future<void> identify(String userId) async {
    identified.add(userId);
  }

  @override
  Future<void> reset() async {
    resetCount++;
  }
}

void main() {
  late _RecordingBackend backend;
  late AnalyticsService service;

  setUp(() {
    backend = _RecordingBackend();
    service = AnalyticsService(backend: backend);
  });

  group('consent-gated by default', () {
    test('starts disabled — capture() no-ops with no consent call ever made', () async {
      expect(service.isEnabled, isFalse);
      await service.capture(const SignupStarted());
      expect(backend.captured, isEmpty);
    });

    test('identify() and reset() also no-op while disabled', () async {
      await service.identify('user-1');
      await service.reset();
      expect(backend.identified, isEmpty);
      expect(backend.resetCount, 0);
    });

    test('enable() turns capture on', () async {
      service.enable();
      expect(service.isEnabled, isTrue);
      await service.capture(const SignupStarted());
      expect(backend.captured, hasLength(1));
    });

    test('identify()/reset() work once enabled', () async {
      service.enable();
      await service.identify('user-abc-123');
      await service.reset();
      expect(backend.identified, ['user-abc-123']);
      expect(backend.resetCount, 1);
    });

    test('disable() after enable() stops future events', () async {
      service.enable();
      await service.capture(const SignupStarted());
      expect(backend.captured, hasLength(1));

      service.disable();
      await service.capture(const SignupStarted());
      expect(backend.captured, hasLength(1), reason: 'no new event after disable()');
    });
  });

  group('typed event API', () {
    test('an event only exposes its own approved typed properties', () {
      const event = ActivityCompleted(domainCode: 'cognitive', completed: true);
      expect(event.name, 'activity_completed');
      expect(event.properties, {'domain_code': 'cognitive', 'completed': true});
    });

    test(
      'filterAndScrubAnalyticsProperties (the actual second-line-of-defense capture() '
      'runs) strips a rogue key that somehow made it into a properties map',
      () {
        // AnalyticsEvent is a sealed class — a bad event subtype literally
        // cannot be constructed outside analytics_event.dart's own
        // library, which is the first line of defense proving itself.
        // This tests the second line directly: the same function
        // capture() calls on every event's properties, given a raw map
        // simulating "a property sneaks in some other way."
        final result = filterAndScrubAnalyticsProperties({
          'screen': 'test_screen',
          'childName': 'Alice',
          'not_on_the_allowlist': 'value',
        });

        expect(result.containsKey('childName'), isFalse);
        expect(result.containsKey('not_on_the_allowlist'), isFalse);
        expect(result['screen'], 'test_screen');
      },
    );
  });

  group('silent failure', () {
    test('a backend throw during capture() never propagates', () async {
      service.enable();
      backend.throwOnCapture = Exception('network down');
      await expectLater(service.capture(const SignupStarted()), completes);
    });
  });
}
