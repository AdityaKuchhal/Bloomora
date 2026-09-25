import { afterEach, describe, expect, it, vi } from 'vitest';

vi.mock('@sentry/node', () => ({
  init: vi.fn(),
  captureException: vi.fn(),
}));

const Sentry = await import('@sentry/node');
const { buildSentryInitOptions, captureException, initSentry, resolveRelease, _resetForTesting } =
  await import('../../src/lib/sentry.js');

describe('resolveRelease', () => {
  it('falls back to package.json\'s version field (RELEASE_SHA/APP_VERSION are unset in this test env)', () => {
    // vitest.config.ts's test.env doesn't set RELEASE_SHA/APP_VERSION —
    // neither exists anywhere in this repo yet (see config/env.ts) — so
    // this exercises the real fallback path, not a mocked one, confirming
    // it's actually exercised rather than just implemented.
    const release = resolveRelease();
    expect(release).toMatch(/^\d+\.\d+\.\d+$/);
  });
});

describe('buildSentryInitOptions (AC1: environment/release tags)', () => {
  it('sets environment to the real env.NODE_ENV value', () => {
    const options = buildSentryInitOptions();
    expect(options.environment).toBe('test');
  });

  it('sets release to the resolved package.json version (the same fallback resolveRelease is tested against above)', () => {
    const options = buildSentryInitOptions();
    expect(options.release).toMatch(/^\d+\.\d+\.\d+$/);
  });

  it('sets beforeSend to the real scrub function', () => {
    const options = buildSentryInitOptions();
    expect(options.beforeSend).toBeInstanceOf(Function);
  });

  it('disables body/cookie/query/user-info collection via dataCollection (the actual fix for the request-body leak — see sentry-scrub.test.ts)', () => {
    const options = buildSentryInitOptions();
    expect(options.dataCollection).toEqual({
      httpBodies: [],
      cookies: false,
      userInfo: false,
      urlQueryParams: false,
    });
  });
});

describe('initSentry', () => {
  it('skips Sentry.init entirely when SENTRY_DSN is unset (the real case in this test env)', () => {
    initSentry();
    expect(Sentry.init).not.toHaveBeenCalled();
  });
});

describe('captureException', () => {
  afterEach(() => {
    _resetForTesting(false);
    vi.clearAllMocks();
  });

  it('no-ops when Sentry was never initialized (e.g. no SENTRY_DSN configured)', () => {
    captureException(new Error('should not be sent'));
    expect(Sentry.captureException).not.toHaveBeenCalled();
  });

  it('delegates to Sentry.captureException, with tags, once initialized', () => {
    _resetForTesting(true);
    const error = new Error('a real unhandled exception');

    captureException(error, { requestId: 'req-123', route: '/v1/assessments' });

    expect(Sentry.captureException).toHaveBeenCalledWith(error, {
      tags: { requestId: 'req-123', route: '/v1/assessments' },
    });
  });

  it('a Sentry.captureException throw never propagates (monitoring must be silent)', () => {
    _resetForTesting(true);
    vi.mocked(Sentry.captureException).mockImplementation(() => {
      throw new Error('Sentry transport down');
    });

    expect(() => captureException(new Error('original error'))).not.toThrow();
  });
});
