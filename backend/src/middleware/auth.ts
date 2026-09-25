import type { NextFunction, Request, Response } from 'express';

import { logger } from '../config/logger.js';
import { supabaseAdmin } from '../lib/supabase-admin.js';
import { sendError } from '../lib/response.js';

const UNAUTHENTICATED = {
  code: 'UNAUTHENTICATED',
  userMessage: 'Please sign in again.',
} as const;

/**
 * Verifies the Supabase JWT via the admin client's own `auth.getUser(token)`
 * call rather than hand-rolling local JWT signature verification. Preferred
 * per the ticket: it's the documented, simpler path, and avoids separately
 * managing the JWT secret/JWKS ourselves. No strong latency concern here to
 * justify local verification instead — flagging the choice rather than
 * silently picking one, per the ticket's instruction.
 *
 * On success: attaches the verified user (id + email) to `req.user` for
 * downstream handlers. On failure: 401 with the same generic message
 * regardless of cause (missing header, malformed token, expired token,
 * Supabase-side verification failure) — never leaks which one, matching
 * FT-004's UnauthorizedError, which expects exactly this fixed message.
 */
export async function requireAuth(req: Request, res: Response, next: NextFunction): Promise<void> {
  const header = req.header('Authorization');
  const token = header?.startsWith('Bearer ') ? header.slice('Bearer '.length).trim() : null;

  if (!token) {
    sendError(res, 401, { ...UNAUTHENTICATED, requestId: req.requestId });
    return;
  }

  try {
    const { data, error } = await supabaseAdmin.auth.getUser(token);
    if (error || !data.user) {
      sendError(res, 401, { ...UNAUTHENTICATED, requestId: req.requestId });
      return;
    }
    req.user = { id: data.user.id, email: data.user.email ?? undefined };
    next();
  } catch (err) {
    logger.warn(
      { requestId: req.requestId, route: req.originalUrl, err },
      'auth verification threw unexpectedly',
    );
    sendError(res, 401, { ...UNAUTHENTICATED, requestId: req.requestId });
  }
}
