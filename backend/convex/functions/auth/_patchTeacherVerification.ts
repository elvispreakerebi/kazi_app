import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const _patchTeacherVerification = mutation({
  args: {
    teacherId: v.id("teachers"),
    code: v.string(),
    now: v.number(),
    field: v.optional(v.string()), // 'reset' = passwordResetCode, else = verificationCode
  },
  handler: async (ctx, args) => {
    if (args.field === 'reset') {
      await ctx.db.patch(args.teacherId, {
        passwordResetCode: args.code,
        passwordResetCodeCreatedAt: args.now,
      });
    } else {
      await ctx.db.patch(args.teacherId, {
        verificationCode: args.code,
        verificationCodeCreatedAt: args.now,
      });
    }
    return "ok";
  },
});
