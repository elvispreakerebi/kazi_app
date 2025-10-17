"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || 'FAKE_SECRET_MUST_REPLACE';

export const verifyTokenAction = action({
  args: {
    token: v.string(),
  },
  handler: async (_ctx, args): Promise<{ valid: boolean, teacherId?: string, error?: string }> => {
    try {
      const decoded = jwt.verify(args.token, JWT_SECRET);
      if (!decoded || typeof decoded !== 'object' || !('teacherId' in decoded)) {
        return { valid: false, error: 'Invalid token payload.' };
      }
      // Defensive: teacherId could be string or Id<"teachers"> (string at runtime)
      return { valid: true, teacherId: String((decoded as any).teacherId) };
    } catch (err: any) {
      return { valid: false, error: err.message };
    }
  }
});
