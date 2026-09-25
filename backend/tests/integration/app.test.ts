import request from 'supertest';
import { describe, expect, it } from 'vitest';

import { createApp } from '../../src/app.js';

describe('GET /health', () => {
  it('returns 200 with a non-sensitive body and works with no Authorization header', async () => {
    const app = createApp();
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
    // Non-sensitive: no version string, no internal hostname/IP, no stack.
    expect(JSON.stringify(response.body)).not.toMatch(/error|stack|key|token/i);
  });

  it('is not rate-limited even after many rapid requests', async () => {
    const app = createApp({ rateLimitOverrides: { windowMs: 60_000, max: 1 } });
    // If /health were behind the limiter, the 2nd+ request would 429.
    const first = await request(app).get('/health');
    const second = await request(app).get('/health');
    expect(first.status).toBe(200);
    expect(second.status).toBe(200);
  });
});

describe('CORS (CORS_ALLOWED_ORIGINS)', () => {
  it('defaults to blocking every origin when unset (no Access-Control-Allow-Origin header)', async () => {
    const app = createApp({ corsAllowedOrigins: [] });
    const response = await request(app).get('/health').set('Origin', 'https://evil-or-unknown.example');

    expect(response.status).toBe(200); // server still answers...
    expect(response.headers['access-control-allow-origin']).toBeUndefined(); // ...but a browser would block it
  });

  it('allows an explicitly configured origin and echoes it back', async () => {
    const app = createApp({ corsAllowedOrigins: ['https://admin.bloomora.app'] });
    const response = await request(app)
      .get('/health')
      .set('Origin', 'https://admin.bloomora.app');

    expect(response.headers['access-control-allow-origin']).toBe('https://admin.bloomora.app');
  });

  it('does not echo back an origin that is not in the configured allow-list', async () => {
    const app = createApp({ corsAllowedOrigins: ['https://admin.bloomora.app'] });
    const response = await request(app)
      .get('/health')
      .set('Origin', 'https://some-other-site.example');

    expect(response.headers['access-control-allow-origin']).toBeUndefined();
  });
});

describe('unknown routes', () => {
  it('returns the standard 404 envelope, not a raw Express default page', async () => {
    const app = createApp();
    const response = await request(app).get('/this-route-does-not-exist');

    expect(response.status).toBe(404);
    expect(response.body).toEqual({
      success: false,
      error: {
        code: 'NOT_FOUND',
        userMessage: 'This item is no longer available.',
        requestId: expect.any(String),
      },
    });
  });
});

describe('X-Request-ID propagation', () => {
  it('generates one when the client sends none, and returns it in the response header', async () => {
    const app = createApp();
    const response = await request(app).get('/health');

    const requestId = response.headers['x-request-id'];
    expect(requestId).toBeDefined();
    expect(requestId).toMatch(/^[0-9a-f-]{36}$/);
  });

  it('echoes the client-sent X-Request-ID back exactly, in both a success and an error response', async () => {
    const app = createApp();
    const clientRequestId = 'client-supplied-id-123';

    const success = await request(app).get('/health').set('X-Request-ID', clientRequestId);
    expect(success.headers['x-request-id']).toBe(clientRequestId);

    const errorResponse = await request(app)
      .get('/nope')
      .set('X-Request-ID', clientRequestId);
    expect(errorResponse.headers['x-request-id']).toBe(clientRequestId);
    expect(errorResponse.body.error.requestId).toBe(clientRequestId);
  });
});

describe('rate limiting', () => {
  it('returns 429 with the standard envelope and a Retry-After header once the limit is exceeded', async () => {
    const app = createApp({ rateLimitOverrides: { windowMs: 60_000, max: 2 } });

    const first = await request(app).get('/v1/children');
    const second = await request(app).get('/v1/children');
    const third = await request(app).get('/v1/children');

    expect(first.status).not.toBe(429);
    expect(second.status).not.toBe(429);
    expect(third.status).toBe(429);
    expect(third.headers['retry-after']).toBeDefined();
    expect(Number(third.headers['retry-after'])).toBeGreaterThan(0);
    expect(third.body).toEqual({
      success: false,
      error: {
        code: 'RATE_LIMITED',
        userMessage: 'Too many requests. Please wait and try again.',
        requestId: expect.any(String),
      },
    });
  });
});
