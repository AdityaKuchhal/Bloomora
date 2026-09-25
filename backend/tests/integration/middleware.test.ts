// These exercise the REAL middleware modules (auth, validate, error-handler,
// request-id) against small test-only routes — not the production v1Router,
// since no domain module has real business routes yet (by this ticket's own
// scope). This is exactly what the ticket's own checklist item 4 suggests:
// "show this with a simple test route ... doesn't need a real business
// endpoint to exist yet."
import express from 'express';
import request from 'supertest';
import { z } from 'zod';
import { afterEach, describe, expect, it, vi } from 'vitest';

vi.mock('../../src/lib/supabase-admin.js', () => ({
  supabaseAdmin: {
    auth: {
      getUser: vi.fn(),
    },
  },
}));

// Imported AFTER the mock so the mocked module is what auth.ts resolves.
const { supabaseAdmin } = await import('../../src/lib/supabase-admin.js');
const { requestIdMiddleware } = await import('../../src/middleware/request-id.js');
const { requireAuth } = await import('../../src/middleware/auth.js');
const { validate } = await import('../../src/middleware/validate.js');
const { errorHandler } = await import('../../src/middleware/error-handler.js');
const { ApiError } = await import('../../src/lib/api-error.js');
const { sendSuccess } = await import('../../src/lib/response.js');
const { logger } = await import('../../src/config/logger.js');

function buildTestApp() {
  const app = express();
  app.use(requestIdMiddleware);
  app.use(express.json());

  app.get('/test/protected', requireAuth, (req, res) => {
    sendSuccess(res, { userId: req.user?.id }, req.requestId);
  });

  const bodySchema = z.object({
    name: z.string().min(1, 'Name is required'),
    age: z.number().int().nonnegative(),
  });
  app.post('/test/validate', validate('body', bodySchema), (req, res) => {
    sendSuccess(res, req.body, req.requestId);
  });

  app.get('/test/boom', () => {
    throw new Error('Something exploded deep in a dependency');
  });

  app.get('/test/typed-error', () => {
    throw new ApiError(409, 'CONFLICT', 'This changed somewhere else. Refresh to continue.');
  });

  app.use((req, res) => {
    res.status(404).json({ success: false, error: { code: 'NOT_FOUND' } });
  });
  app.use(errorHandler);
  return app;
}

const mockGetUser = supabaseAdmin.auth.getUser as unknown as ReturnType<typeof vi.fn>;

afterEach(() => {
  mockGetUser.mockReset();
});

describe('requireAuth', () => {
  it('a request with no Authorization header is rejected with the standard 401 envelope', async () => {
    const app = buildTestApp();
    const response = await request(app).get('/test/protected');

    expect(response.status).toBe(401);
    expect(response.body).toEqual({
      success: false,
      error: {
        code: 'UNAUTHENTICATED',
        userMessage: 'Please sign in again.',
        requestId: expect.any(String),
      },
    });
    expect(mockGetUser).not.toHaveBeenCalled();
  });

  it('an invalid/rejected token is rejected with the same generic 401 envelope', async () => {
    mockGetUser.mockResolvedValue({ data: { user: null }, error: { message: 'invalid JWT' } });
    const app = buildTestApp();
    const response = await request(app)
      .get('/test/protected')
      .set('Authorization', 'Bearer garbage-token');

    expect(response.status).toBe(401);
    expect(response.body.error.userMessage).toBe('Please sign in again.');
    // Never leaks why it failed.
    expect(JSON.stringify(response.body)).not.toContain('invalid JWT');
  });

  it('an expired token is rejected with the identical generic message as an invalid one', async () => {
    mockGetUser.mockResolvedValue({ data: { user: null }, error: { message: 'JWT expired' } });
    const app = buildTestApp();
    const response = await request(app)
      .get('/test/protected')
      .set('Authorization', 'Bearer expired-token');

    expect(response.status).toBe(401);
    expect(response.body.error.userMessage).toBe('Please sign in again.');
    expect(JSON.stringify(response.body)).not.toContain('expired');
  });

  it('a valid token passes through: req.user carries the verified user id downstream', async () => {
    mockGetUser.mockResolvedValue({
      data: { user: { id: 'user-abc-123', email: 'parent@example.com' } },
      error: null,
    });
    const app = buildTestApp();
    const response = await request(app)
      .get('/test/protected')
      .set('Authorization', 'Bearer a-real-looking-token');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      success: true,
      data: { userId: 'user-abc-123' },
      requestId: expect.any(String),
    });
    expect(mockGetUser).toHaveBeenCalledWith('a-real-looking-token');
  });
});

describe('validate', () => {
  it('a request failing schema validation returns 422 with fieldErrors, no raw Zod internals', async () => {
    const app = buildTestApp();
    const response = await request(app)
      .post('/test/validate')
      .send({ name: '', age: 'not-a-number' });

    expect(response.status).toBe(422);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('VALIDATION_FAILED');
    expect(response.body.error.fieldErrors).toBeDefined();
    expect(response.body.error.fieldErrors.name).toBeDefined();
    expect(response.body.error.fieldErrors.age).toBeDefined();
    // No raw Zod error object shape (issues[]/path[]/_zod, etc.) leaked.
    const raw = JSON.stringify(response.body);
    expect(raw).not.toContain('"issues"');
    expect(raw).not.toContain('"path"');
    expect(raw).not.toContain('ZodError');
  });

  it('a request passing validation reaches the handler with the parsed body', async () => {
    const app = buildTestApp();
    const response = await request(app)
      .post('/test/validate')
      .send({ name: 'Kiddo', age: 4 });

    expect(response.status).toBe(200);
    expect(response.body.data).toEqual({ name: 'Kiddo', age: 4 });
  });
});

describe('error-handler', () => {
  it('an unhandled thrown error returns the generic 500 envelope, never the raw message', async () => {
    const app = buildTestApp();
    const response = await request(app).get('/test/boom');

    expect(response.status).toBe(500);
    expect(response.body).toEqual({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        userMessage: 'Something went wrong on our side. Please try again.',
        requestId: expect.any(String),
      },
    });
    expect(JSON.stringify(response.body)).not.toContain('exploded');
  });

  it('the full error (message, stack) is logged server-side, tagged with the same request ID as the response — and never in the response body', async () => {
    const logSpy = vi.spyOn(logger, 'error').mockImplementation(() => undefined as never);
    const app = buildTestApp();

    const response = await request(app).get('/test/boom').set('X-Request-ID', 'trace-me-log');

    expect(logSpy).toHaveBeenCalledTimes(1);
    const [logPayload] = logSpy.mock.calls[0]!;
    expect(logPayload).toMatchObject({
      requestId: 'trace-me-log',
      route: '/test/boom',
      method: 'GET',
      err: {
        message: 'Something exploded deep in a dependency',
      },
    });
    expect((logPayload as { err: { stack?: string } }).err.stack).toContain(
      'Something exploded deep in a dependency',
    );
    // Same request ID ties the log line to the response the user saw.
    expect(response.body.error.requestId).toBe('trace-me-log');

    logSpy.mockRestore();
  });

  it('the 500 response requestId matches the client-sent X-Request-ID', async () => {
    const app = buildTestApp();
    const response = await request(app).get('/test/boom').set('X-Request-ID', 'trace-me-500');

    expect(response.body.error.requestId).toBe('trace-me-500');
    expect(response.headers['x-request-id']).toBe('trace-me-500');
  });

  it('a thrown ApiError uses its own status/code/message, not the generic 500 path', async () => {
    const app = buildTestApp();
    const response = await request(app).get('/test/typed-error');

    expect(response.status).toBe(409);
    expect(response.body.error.code).toBe('CONFLICT');
    expect(response.body.error.userMessage).toBe('This changed somewhere else. Refresh to continue.');
  });
});
