import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import bcrypt from "bcryptjs";
import { capitalizeWords } from "../../utils/text";
import { validateEmail, validatePassword } from "../../utils/validation";

export const editTeacherAccount = mutation({
  args: {
    teacherId: v.id("teachers"),
    name: v.optional(v.string()),
    email: v.optional(v.string()),
    password: v.optional(v.string()), // plain password, will be hashed
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher) throw new Error("Teacher not found.");
    const updates: Record<string, any> = {};
    if (args.name && args.name !== teacher.name) {
      updates.name = capitalizeWords(args.name.trim());
    }
    if (args.email && args.email !== teacher.email) {
      validateEmail(args.email);
      // Ensure unique email
      const conflict = await ctx.db
        .query("teachers")
        .withIndex("by_email", q => q.eq("email", args.email!))
        .first();
      if (conflict && conflict._id !== args.teacherId) {
        throw new Error("Email address already in use.");
      }
      updates.email = args.email.trim().toLowerCase();
    }
    if (args.password) {
      validatePassword(args.password);
      updates.hashedPassword = await bcrypt.hash(args.password, 10);
    }
    if (Object.keys(updates).length === 0) {
      return { updated: false };
    }
    await ctx.db.patch(args.teacherId, updates);
    return { updated: true };
  },
});
