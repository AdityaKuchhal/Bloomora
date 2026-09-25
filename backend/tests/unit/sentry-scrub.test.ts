import type { ErrorEvent } from '@sentry/node';
import { describe, expect, it } from 'vitest';

import { scrubSentryEvent } from '../../src/lib/sentry-scrub.js';

describe('scrubSentryEvent', () => {
  it('strips a deliberately-injected childName key from extra', () => {
    const event = { extra: { route: '/v1/assessments', childName: 'Alice Smith' } } as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.extra).not.toHaveProperty('childName');
    expect(result.extra?.route).toBe('/v1/assessments');
  });

  it('strips a deliberately-injected sensitive key from tags', () => {
    const event = {
      tags: { route: '/v1/assessments', authToken: 'super-secret-token' },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.tags).not.toHaveProperty('authToken');
    expect(result.tags?.route).toBe('/v1/assessments');
  });

  it('removes the Authorization header from request data', () => {
    const event = {
      request: {
        headers: { Authorization: 'Bearer eyFakeTokenForTest', 'Content-Type': 'application/json' },
      },
    } as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.request?.headers).not.toHaveProperty('Authorization');
    expect(result.request?.headers?.['Content-Type']).toBe('application/json');
  });

  it('clears user.email while preserving the pseudonymous user id', () => {
    const event = { user: { id: 'user-abc-123', email: 'parent@example.com' } } as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.user).not.toHaveProperty('email');
    expect(result.user?.id).toBe('user-abc-123');
  });

  it('drops the entire request body, even though none of its keys are individually denylisted (the real gap: a raw assessment-response body has no fixed key set to match against)', () => {
    const event = {
      request: {
        method: 'PATCH',
        url: '/v1/assessments/abc123/responses',
        data: {
          responses: [
            { questionId: 'q1', score: 2 },
            { questionId: 'q2', score: 0 },
          ],
        },
      },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.request).not.toHaveProperty('data');
    // Method/URL are low-sensitivity route metadata — kept.
    expect(result.request?.method).toBe('PATCH');
    expect(result.request?.url).toBe('/v1/assessments/abc123/responses');
  });

  it('drops request.cookies entirely', () => {
    const event = {
      request: { cookies: { session: 'sensitive-session-cookie-value' } },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.request).not.toHaveProperty('cookies');
  });

  it('drops request.query_string entirely', () => {
    const event = {
      request: { query_string: 'token=abc123&user_email=parent%40example.com' },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.request).not.toHaveProperty('query_string');
  });

  it('scrubs request.headers via the full denylist, not just a literal "Authorization" check', () => {
    const event = {
      request: { headers: { 'X-Auth-Token': 'custom-header-token', Accept: 'application/json' } },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    expect(result.request?.headers).not.toHaveProperty('X-Auth-Token');
    expect(result.request?.headers?.Accept).toBe('application/json');
  });

  it('scrubs recursively into contexts', () => {
    const event = {
      contexts: { extra_context: { diagnosis: 'sensitive text', domain_code: 'cognitive' } },
    } as unknown as ErrorEvent;

    const result = scrubSentryEvent(event);

    const nested = (result.contexts as Record<string, unknown>).extra_context as Record<
      string,
      unknown
    >;
    expect(nested).not.toHaveProperty('diagnosis');
    expect(nested.domain_code).toBe('cognitive');
  });
});
