import { describe, expect, it } from 'vitest';

import { isDeniedPropertyKey, scrubDeniedKeys } from '../../src/lib/pii-scrub.js';

describe('isDeniedPropertyKey', () => {
  it('matches known-sensitive keys regardless of case/separator style', () => {
    for (const key of ['childName', 'child_name', 'CHILD-NAME', 'dob', 'dateOfBirth']) {
      expect(isDeniedPropertyKey(key), `${key} should be denied`).toBe(true);
    }
  });

  it('does not match approved property keys', () => {
    for (const key of ['screen', 'domain_code', 'completed', 'route', 'method']) {
      expect(isDeniedPropertyKey(key), `${key} should be allowed`).toBe(false);
    }
  });
});

describe('scrubDeniedKeys', () => {
  it('removes a deliberately-injected sensitive key and keeps the rest', () => {
    const result = scrubDeniedKeys({
      route: '/v1/assessments',
      childName: 'Alice',
      domain_code: 'cognitive',
    });

    expect(result).not.toHaveProperty('childName');
    expect(result.route).toBe('/v1/assessments');
    expect(result.domain_code).toBe('cognitive');
  });

  it('scrubs recursively into nested objects', () => {
    const result = scrubDeniedKeys({
      route: '/v1/assessments',
      nested: { authToken: 'secret', domain_code: 'cognitive' },
    });

    expect(result.nested).not.toHaveProperty('authToken');
    expect((result.nested as Record<string, unknown>).domain_code).toBe('cognitive');
  });

  it('never mutates the input object', () => {
    const input = { childName: 'Alice', route: '/x' };
    scrubDeniedKeys(input);
    expect(input).toHaveProperty('childName');
  });
});
