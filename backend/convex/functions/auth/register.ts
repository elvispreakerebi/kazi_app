import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";
import { capitalizeWords } from "../../utils/text";

export const register = mutation({
  args: {
    email: v.string(),
    password: v.string(),
    name: v.string(),
  },
  handler: async (ctx, args) => {
    const byEmail = await ctx.db
      .query("teachers")
      .withIndex("by_email", (q) => q.eq("email", args.email))
      .unique();
    if (byEmail) {
      throw new Error("A teacher with that email already exists.");
    }
    const passwordHash = await bcrypt.hash(args.password, 10);
    const now = Date.now();
    const language = "english";
    const capitalizedName = capitalizeWords(args.name);
    const teacherId = await ctx.db.insert("teachers", {
      email: args.email,
      passwordHash,
      name: capitalizedName,
      createdAt: now,
      language,
    });
    return { id: teacherId, email: args.email };
  },
});
