import { query } from "../../_generated/server";
import { v } from "convex/values";

export const findTeacherByEmail = query({
  args: { email: v.string() },
  returns: v.union(
    v.object({
      _id: v.id("teachers"),
      email: v.string(),
      name: v.optional(v.string()),
      createdAt: v.number(),
      language: v.union(v.literal("english"), v.literal("french"), v.literal("kiryanwanda")),
      hashedPassword: v.optional(v.string()),
      lastLogin: v.optional(v.number()),
      googleId: v.optional(v.string()),
    }),
    v.null()
  ),
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query("teachers")
      .withIndex("by_email", q => q.eq("email", args.email))
      .unique();
    return user ? user : null;
  }
});
