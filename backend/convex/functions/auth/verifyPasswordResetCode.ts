import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";

export const verifyPasswordResetCode = mutation({
  args: { email: v.string(), code: v.string() },
  handler: async (ctx, args): Promise<{ ok: boolean; error?: string }> => {
    const teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: args.email });
    if (!teacher || !teacher.passwordResetCode || !teacher.passwordResetCodeCreatedAt) {
      return { ok: false, error: "Invalid or expired code." };
    }
    // TTL 15 min
    if (Date.now() - teacher.passwordResetCodeCreatedAt > 15 * 60 * 1000) {
      return { ok: false, error: "Code expired. Please request a new one." };
    }
    if (teacher.passwordResetCode !== args.code) {
      return { ok: false, error: "Invalid code." };
    }
    // Optionally clear code (can defer till password reset)
    return { ok: true };
  },
});
