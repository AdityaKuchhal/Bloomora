export {};

declare global {
  namespace Express {
    interface Request {
      /** Set by middleware/request-id.ts — the earliest middleware in the chain. */
      requestId: string;
      /** Set by middleware/auth.ts on a verified request. Absent on public routes. */
      user?: {
        id: string;
        email?: string;
      };
    }
  }
}
