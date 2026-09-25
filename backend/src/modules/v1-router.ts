import { Router } from 'express';

import { requireAuth } from '../middleware/auth.js';
import { activitiesRouter } from './activities/activities.routes.js';
import { aiRouter } from './ai/ai.routes.js';
import { assessmentRouter } from './assessments/assessment.routes.js';
import { childrenRouter } from './children/children.routes.js';
import { consentRouter } from './consent/consent.routes.js';
import { prioritiesRouter } from './priorities/priorities.routes.js';
import { recommendationsRouter } from './recommendations/recommendations.routes.js';

/**
 * The /v1 mount point every future domain module plugs into. Per FT-004's
 * confirmed architecture rule (writes/mutations go through this API, no
 * exceptions), everything under here requires a verified identity —
 * requireAuth is applied once, at the router level, rather than trusting
 * each future domain ticket to remember to add it per-route.
 */
export const v1Router = Router();

v1Router.use(requireAuth);

v1Router.use('/children', childrenRouter);
v1Router.use('/assessments', assessmentRouter);
v1Router.use('/priorities', prioritiesRouter);
v1Router.use('/activities', activitiesRouter);
v1Router.use('/recommendations', recommendationsRouter);
v1Router.use('/ai', aiRouter);
v1Router.use('/consent', consentRouter);
