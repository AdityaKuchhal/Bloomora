import { Router } from 'express';

/**
 * Stub — FT-021+ owns this module's real routes/controller/service/schema/
 * scoring-service. TRD §4 lists 5 files for this module
 * (assessment.routes.ts, assessment.controller.ts, assessment.service.ts,
 * assessment.schema.ts, scoring.service.ts); only this one is created now
 * since it's the one with independent existence as a literal mount point —
 * an empty controller/service/schema file has no equivalent role and would
 * just be clutter until there's a real route calling into it.
 *
 * With no routes registered, any request under `/v1/assessments` falls
 * through to app.ts's standard 404 handler.
 */
export const assessmentRouter = Router();
