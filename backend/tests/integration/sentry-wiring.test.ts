// Proves the real middleware/error-handler.ts (not a reimplementation)
// actually calls into lib/sentry.ts's captureException for unhandled
// exceptions, and does NOT for an intentional, already-handled ApiError —
// matching "backend exceptions are captured with environment/release
// metadata" without treating a handled 4xx as an "exception."
import express from 'express';
import request from 'supertest';
import { afterEach, describe, expect, it, vi } from 'vitest';

vi.mock('../../src/lib/sentry.js', () => ({
  captureException: vi.fn(),
}));

const { captureException } = await import('../../src/lib/sentry.js');
const { requestIdMiddleware } = await import('../../src/middleware/request-id.js');
const { errorHandler } = await import('../../src/middleware/error-handler.js');
const { ApiError } = await import('../../src/lib/api-error.js');

function buildTestApp() {
  const app = express();
  app.use(requestIdMiddleware);

  app.get('/test/boom', () => {
    throw new Error('a real unhandled exception for this test');
  });
  app.get('/test/typed-error', () => {
    throw new ApiError(409, 'CONFLICT', 'This changed somewhere else. Refresh to continue.');
  });

  app.use(errorHandler);
  return app;
}

describe('error-handler -> Sentry wiring', () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  it('an unhandled exception is passed to captureException, tagged with the request ID', async () => {
    const app = buildTestApp();

    await request(app).get('/test/boom').set('X-Request-ID', 'trace-me-sentry');

    expect(captureException).toHaveBeenCalledTimes(1);
    const [capturedError, tags] = vi.mocked(captureException).mock.calls[0]!;
    expect((capturedError as Error).message).toBe('a real unhandled exception for this test');
    expect(tags).toMatchObject({ requestId: 'trace-me-sentry', route: '/test/boom' });
  });

  it('an intentional ApiError (an already-handled 4xx) is NOT sent to Sentry', async () => {
    const app = buildTestApp();

    await request(app).get('/test/typed-error');

    expect(captureException).not.toHaveBeenCalled();
  });
});
