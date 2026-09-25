import type { NextFunction, Request, Response } from 'express';
import type { ZodTypeAny } from 'zod';

import { sendError } from '../lib/response.js';

type ValidationTarget = 'body' | 'params' | 'query';

/**
 * Reusable request-validation middleware factory. On failure, returns the
 * standard error envelope with `fieldErrors` built from the Zod error's
 * issues — never the raw ZodError object or its internal `path`/`code`
 * structure dumped wholesale.
 *
 * Uses 422 consistently for every validation failure (malformed shape and
 * failed semantic validation alike) rather than splitting 400 vs 422 —
 * the ticket left this as a judgment call as long as it's consistent; this
 * also matches how FT-004's Flutter client already treats 422 (field-level,
 * no auto-retry, `fieldErrors` surfaced) for exactly this kind of failure.
 */
export function validate(target: ValidationTarget, schema: ZodTypeAny) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req[target]);
    if (!result.success) {
      const fieldErrors: Record<string, string> = {};
      for (const issue of result.error.issues) {
        const path = issue.path.length > 0 ? issue.path.join('.') : target;
        if (!(path in fieldErrors)) {
          fieldErrors[path] = issue.message;
        }
      }
      sendError(res, 422, {
        code: 'VALIDATION_FAILED',
        userMessage: 'Please check your input and try again.',
        requestId: req.requestId,
        fieldErrors,
      });
      return;
    }
    req[target] = result.data;
    next();
  };
}
