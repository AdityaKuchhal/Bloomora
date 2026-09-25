import pino from 'pino';

import { env } from './env.js';

// pino: standard structured-JSON Node logger, most common choice for this
// stack (Express + TS) — no library was named in the TRD, flagging the
// pick per the ticket's instruction to do so.
//
// `redact` enforces Security & Access §6.2: never log tokens, passwords,
// or secrets, even if a caller accidentally logs a whole request/response
// object. `remove: true` strips the key entirely rather than replacing it
// with "[Redacted]", so accidental logging of e.g. a full Supabase session
// object doesn't even hint at field shape.
export const logger = pino({
  level: env.LOG_LEVEL,
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.Authorization',
      'req.headers.cookie',
      'headers.authorization',
      '*.password',
      '*.token',
      '*.accessToken',
      '*.access_token',
      '*.refreshToken',
      '*.refresh_token',
      '*.serviceRoleKey',
      '*.service_role_key',
      '*.apiKey',
      '*.api_key',
    ],
    remove: true,
  },
});
