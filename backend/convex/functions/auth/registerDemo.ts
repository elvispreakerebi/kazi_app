import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from "../../utils/text";

export const registerDemo = mutation({
  args: {
    email: v.string(),
    password: v.string(),
    name: v.string(),
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
    // WARNING: For demonstration only, password is stored as-is (must be hashed in production!)
    const teacherId = await ctx.db.insert("teachers", {
      email: args.email,
      name,
      createdAt: now,
      language: "english",
      hashedPassword: args.password,
    });
    return { id: teacherId, email: args.email };
  },
});
