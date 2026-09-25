import { randomUUID } from 'node:crypto';

import type { NextFunction, Request, Response } from 'express';

/**
 * Must be the earliest middleware in the chain (before rate-limit, before
 * auth) — every downstream handler, the logger, and the error handler all
 * reference `req.requestId`, and every response (success or error) for
 * this request carries the same value back in its envelope.
 *
 * Not in the TRD §4 middleware/ list (which names auth.ts, error-handler.ts,
 * rate-limit.ts) — that list reads as illustrative, not exhaustive, and the
 * ticket explicitly requires this behavior, so it's added as its own file
 * rather than folded into another middleware for a concern this narrow and
 * this early in the chain.
 */
export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const incoming = req.header('X-Request-ID');
  const requestId = incoming && incoming.trim().length > 0 ? incoming.trim() : randomUUID();
  req.requestId = requestId;
  res.setHeader('X-Request-ID', requestId);
  next();
}
