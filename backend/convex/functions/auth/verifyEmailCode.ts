import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { validateEmail, ValidationError } from "../../utils/validation";

const CODE_TTL_MS = 15 * 60 * 1000; // 15 min

export const verifyEmailCode = mutation({
  args: { email: v.string(), code: v.string() },
  handler: async (ctx, args): Promise<{ ok: boolean; error?: string }> => {
    try {
      validateEmail(args.email);
    } catch (err: any) {
      if (err instanceof ValidationError) {
        return { ok: false, error: err.message };
      }
      return { ok: false, error: "Unexpected error validating email." };
    }
    const teachers = await ctx.db
      .query("teachers")
      .withIndex("by_email", q => q.eq("email", args.email))
      .unique();
    if (!teachers) {
      return { ok: false, error: "Invalid code or expired." };
    }
    if (!teachers.verificationCode || !teachers.verificationCodeCreatedAt) {
      return { ok: false, error: "Invalid code or expired." };
    }
    const tooOld =
      Date.now() - teachers.verificationCodeCreatedAt > CODE_TTL_MS;
    if (tooOld || teachers.verificationCode !== args.code) {
      return { ok: false, error: "Invalid code or expired." };
    }
    await ctx.db.patch(teachers._id, {
      verified: true,
      verificationCode: undefined,
      verificationCodeCreatedAt: undefined,
    });
    return { ok: true };
  },
});
