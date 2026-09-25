import 'package:flutter_test/flutter_test.dart';

import 'package:bloomora/core/monitoring/pii_scrub.dart';

void main() {
  group('isDeniedPropertyKey', () {
    test('matches known-sensitive keys regardless of case/separator style', () {
      for (final key in ['childName', 'child_name', 'CHILD-NAME', 'dob', 'dateOfBirth']) {
        expect(isDeniedPropertyKey(key), isTrue, reason: '$key should be denied');
      }
    });

    test('does not match approved property keys', () {
      for (final key in ['screen', 'domain_code', 'completed', 'duration_bucket', 'app_version']) {
        expect(isDeniedPropertyKey(key), isFalse, reason: '$key should be allowed');
      }
    });
  });

  group('scrubDeniedKeys', () {
    test('removes a deliberately-injected sensitive key and keeps the rest', () {
      final result = scrubDeniedKeys({
        'screen': 'onboarding',
        'childName': 'Alice',
        'domain_code': 'cognitive',
      });

      expect(result.containsKey('childName'), isFalse);
      expect(result['screen'], 'onboarding');
      expect(result['domain_code'], 'cognitive');
    });

    test('scrubs recursively into nested maps', () {
      final result = scrubDeniedKeys({
        'screen': 'assessment',
        'nested': {'authToken': 'secret', 'domain_code': 'cognitive'},
      });

      final nested = result['nested'] as Map<String, Object?>;
      expect(nested.containsKey('authToken'), isFalse);
      expect(nested['domain_code'], 'cognitive');
    });

    test('never mutates the input map', () {
      final input = {'childName': 'Alice', 'screen': 'x'};
      scrubDeniedKeys(input);
      expect(input.containsKey('childName'), isTrue);
    });
  });
}
