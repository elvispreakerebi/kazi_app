import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const _patchTeacherVerification = mutation({
  args: { 
    teacherId: v.id("teachers"),
    code: v.string(),
    now: v.number()
  },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.teacherId, {
      verificationCode: args.code,
      verificationCodeCreatedAt: args.now,
      verified: false,
    });
    return null;
  },
});
