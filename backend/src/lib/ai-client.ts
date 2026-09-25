import Anthropic from '@anthropic-ai/sdk';

import { env } from '../config/env.js';

/**
 * NOTE ON THE FILENAME: the TRD §4 module structure names this file
 * `lib/openai.ts`. This project's confirmed AI provider is Anthropic, not
 * OpenAI — see docs/audit-findings.md (Section A + Open Question 4,
 * resolved) and backend/.env.example, which has `ANTHROPIC_API_KEY` and no
 * `OPENAI_*` vars at all. Naming this file `openai.ts` while constructing
 * an Anthropic client would bake a stale assumption into the file's own
 * name for anyone who opens it later, so it's named `ai-client.ts`
 * instead. Flagging this deviation explicitly rather than silently
 * matching the TRD's literal filename.
 *
 * Client construction only, per this ticket's scope — no calls are wired
 * up anywhere. Real usage starts at FT-037.
 */
export const aiClient = new Anthropic({ apiKey: env.ANTHROPIC_API_KEY });
