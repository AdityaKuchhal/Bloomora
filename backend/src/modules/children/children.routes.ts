import { Router } from 'express';

/**
 * Stub — FT-018 owns this module's real routes/controller/service. This
 * empty router exists purely so `/v1/children` has a mount point; with no
 * routes registered, any request under it falls through to app.ts's
 * standard 404 handler.
 */
export const childrenRouter = Router();
