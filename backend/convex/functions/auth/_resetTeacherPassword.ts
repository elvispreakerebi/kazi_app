import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const _resetTeacherPassword = mutation({
  args: {
    teacherId: v.id("teachers"),
    hashedPassword: v.string(),
  },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.teacherId, {
      hashedPassword: args.hashedPassword,
      passwordResetCode: undefined,
      passwordResetCodeCreatedAt: undefined,
    });
    return "ok";
  },
});
