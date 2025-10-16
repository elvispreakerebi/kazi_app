import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from "../../utils/text";
import { api } from "../../_generated/api";

export const createAccount = mutation({
  args: {
    email: v.string(),
    name: v.string(),
    hashedPassword: v.string(),
    googleId: v.optional(v.string()), // allow optional googleId
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
    const doc = {
      email: args.email,
      name,
      createdAt: now,
      language: "english" as const,
      hashedPassword: args.hashedPassword,
      ...(args.googleId ? { googleId: args.googleId } : {}),
    };
    const teacherId = await ctx.db.insert("teachers", doc);
    // TODO: Trigger sendVerificationEmailAction from the HTTP or action layer after createAccount runs successfully (mutations can't call actions directly)
    return { id: teacherId, email: args.email };
  },
});
