/**
 * Throw this (or pass to `next(err)`) from anywhere downstream of
 * middleware/error-handler.ts for a typed, intentional 4xx — the error
 * handler recognizes it and uses its fields directly for the response
 * envelope. Anything else thrown (a genuine bug, a rejected promise from a
 * dependency, ...) falls through to the handler's generic 500 path
 * instead.
 */
export class ApiError extends Error {
  readonly statusCode: number;
  readonly code: string;
  readonly userMessage: string;
  readonly fieldErrors?: Record<string, string>;

  constructor(
    statusCode: number,
    code: string,
    userMessage: string,
    fieldErrors?: Record<string, string>,
  ) {
    super(userMessage);
    this.name = 'ApiError';
    this.statusCode = statusCode;
    this.code = code;
    this.userMessage = userMessage;
    this.fieldErrors = fieldErrors;
  }
}
