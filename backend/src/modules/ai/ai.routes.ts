import { Router } from 'express';

/**
 * Stub — FT-037 owns this module's real routes/controller/service/prompts/
 * output-schema, and is also where lib/ai-client.ts's Anthropic client
 * first gets an actual call site. Empty router as a mount point only;
 * falls through to app.ts's standard 404 handler.
 */
export const aiRouter = Router();
