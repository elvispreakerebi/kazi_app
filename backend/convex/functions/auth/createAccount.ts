import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from "../../utils/text";

export const createAccount = mutation({
  args: {
    email: v.string(),
    name: v.string(),
    hashedPassword: v.string(),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("teachers")
      .withIndex("by_email", q => q.eq("email", args.email))
      .unique();
    if (existing) {
      throw new Error("Account already exists.");
    }
    const now = Date.now();
    const name = capitalizeWords(args.name);
    const teacherId = await ctx.db.insert("teachers", {
      email: args.email,
      name,
      createdAt: now,
      language: "english",
      hashedPassword: args.hashedPassword,
    });
    return { id: teacherId, email: args.email };
  },
});
