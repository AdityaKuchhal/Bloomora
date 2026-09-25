import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:bloomora/core/monitoring/sentry_scrub.dart';

void main() {
  group('scrubSentryEvent', () {
    test('strips a deliberately-injected childName key from extra', () {
      final event = SentryEvent(
        // ignore: deprecated_member_use
        extra: {'screen': 'assessment', 'childName': 'Alice Smith'},
      );

      final result = scrubSentryEvent(event, Hint());

      // ignore: deprecated_member_use
      expect(result!.extra!.containsKey('childName'), isFalse);
      // ignore: deprecated_member_use
      expect(result.extra!['screen'], 'assessment');
    });

    test('strips a deliberately-injected sensitive key from tags', () {
      final event = SentryEvent(
        tags: {'screen': 'assessment', 'authToken': 'super-secret-token'},
      );

      final result = scrubSentryEvent(event, Hint());

      expect(result!.tags!.containsKey('authToken'), isFalse);
      expect(result.tags!['screen'], 'assessment');
    });

    test('removes the Authorization header from request data', () {
      final event = SentryEvent(
        request: SentryRequest(headers: {
          'Authorization': 'Bearer eyFakeTokenForTest',
          'Content-Type': 'application/json',
        }),
      );

      final result = scrubSentryEvent(event, Hint());

      expect(result!.request!.headers.containsKey('Authorization'), isFalse);
      expect(result.request!.headers['Content-Type'], 'application/json');
    });

    test('clears user.email while preserving the pseudonymous user id', () {
      final event = SentryEvent(
        user: SentryUser(id: 'user-abc-123', email: 'parent@example.com'),
      );

      final result = scrubSentryEvent(event, Hint());

      expect(result!.user!.email, isNull);
      expect(result.user!.id, 'user-abc-123');
    });

    test('drops the user entirely if email was its only identifying field', () {
      final event = SentryEvent(user: SentryUser(email: 'parent@example.com'));

      final result = scrubSentryEvent(event, Hint());

      expect(result!.user, isNull);
    });

    test('a fabricated stack-trace-shaped message is left alone (scrub targets keys, not free text)', () {
      // Documents the actual scope: this scrub targets structured
      // key/value data (extra/tags/user/request), not free-text scanning
      // of the exception message itself — see sentry_scrub.dart's doc
      // comment.
      final event = SentryEvent(message: SentryMessage('TypeError at line 42'));

      final result = scrubSentryEvent(event, Hint());

      expect(result!.message!.formatted, 'TypeError at line 42');
    });
  });
}
