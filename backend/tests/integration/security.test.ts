// Two standalone security confirmations, isolated in their own file so
// their module mocks don't interfere with other integration test files:
//  1. The Authorization/Bearer token never appears anywhere in captured
//     log output (Security & Access §6.2).
//  2. GET /health answers without ever touching Supabase — even when
//     Supabase would throw on any call, /health must still return 200.
import request from 'supertest';
import { afterEach, describe, expect, it, vi } from 'vitest';

vi.mock('../../src/lib/supabase-admin.js', () => ({
  supabaseAdmin: {
    auth: {
      getUser: vi.fn(() => {
        throw new Error('supabase should be unreachable in this test — if this ran, /health depends on it');
      }),
    },
  },
}));

const { createApp } = await import('../../src/app.js');
const { logger } = await import('../../src/config/logger.js');

describe('logger never captures the bearer token', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('a request with a real-looking Bearer token never has that token appear in any logger.* call', async () => {
    // Spying directly on logger.info/warn/error captures exactly what our
    // own code chose to pass to the logger — precise regardless of pino's
    // internal destination/serialization mechanics (pino's default
    // destination writes via a raw file-descriptor stream, not
    // process.stdout.write, so spying at that layer would miss real
    // output; spying on the public logger methods doesn't have that gap).
    const infoSpy = vi.spyOn(logger, 'info');
    const warnSpy = vi.spyOn(logger, 'warn');
    const errorSpy = vi.spyOn(logger, 'error');

    const app = createApp();
    const suspiciousToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.THIS_SHOULD_NEVER_APPEAR_IN_A_LOG_LINE.signature-part';

    await request(app).get('/health').set('Authorization', `Bearer ${suspiciousToken}`);
    await request(app).get('/v1/children').set('Authorization', `Bearer ${suspiciousToken}`);

    const allCalls = [...infoSpy.mock.calls, ...warnSpy.mock.calls, ...errorSpy.mock.calls];
    const serialized = allCalls.map((args) => JSON.stringify(args)).join('\n');

    expect(serialized).not.toContain(suspiciousToken);
    expect(serialized).not.toContain('THIS_SHOULD_NEVER_APPEAR_IN_A_LOG_LINE');
    // Sanity check the spies actually captured real log calls, so a
    // vacuous "nothing was logged at all" couldn't make this pass emptily.
    expect(infoSpy).toHaveBeenCalled();
    expect(serialized).toContain('request completed');
  });
});

describe('GET /health has no Supabase dependency', () => {
  it('still returns 200 even when the Supabase client would throw on any call', async () => {
    const app = createApp();
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
  });
});
