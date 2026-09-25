import type { Response } from 'express';

/**
 * The standard success/error envelope shared with the Flutter client
 * (FT-004's app_api_client.dart). Every route/controller must go through
 * these two helpers rather than hand-building `res.json(...)` — so the
 * shape can't drift per-route.
 */
export function sendSuccess<T>(
  res: Response,
  data: T,
  requestId: string,
  statusCode = 200,
): Response {
  return res.status(statusCode).json({ success: true, data, requestId });
}

export interface ErrorEnvelopeOptions {
  code: string;
  userMessage: string;
  requestId: string;
  fieldErrors?: Record<string, string>;
}

export function sendError(
  res: Response,
  statusCode: number,
  options: ErrorEnvelopeOptions,
): Response {
  return res.status(statusCode).json({
    success: false,
    error: {
      code: options.code,
      userMessage: options.userMessage,
      requestId: options.requestId,
      ...(options.fieldErrors ? { fieldErrors: options.fieldErrors } : {}),
    },
  });
}
