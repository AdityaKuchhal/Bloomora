// Import order matters here: ./config/env.js is imported transitively by
// ./app.js (via its middleware/lib imports) before createApp() is ever
// called, so environment validation already ran — and would already have
// crashed the process with a clear error — before any Express construction
// happens. This satisfies the AC ("starts only when required server
// environment variables pass validation") without needing extra
// sequencing code here.
import { createApp } from './app.js';
import { env } from './config/env.js';
import { logger } from './config/logger.js';

const app = createApp();

app.listen(env.PORT, () => {
  logger.info({ port: env.PORT, nodeEnv: env.NODE_ENV }, 'backend started');
});
