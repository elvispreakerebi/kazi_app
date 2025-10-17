import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from '../../utils/text';

export const addClass = mutation({
  args: {
    teacherId: v.id("teachers"),
    name: v.string(),
    gradeLevel: v.string(),
    academicYear: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Check that teacher exists and is verified
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher) {
      throw new Error("Teacher not found.");
    }
    if (!teacher.verified) {
      throw new Error("Account must be verified to add a class.");
    }
    // Check for duplicate class by name & grade (optional, can be adjusted)
    const existing = await ctx.db
      .query("classes")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .collect();
    const duplicate = existing.find(
      c => c.name.toLowerCase() === args.name.toLowerCase() && c.gradeLevel === args.gradeLevel
    );
    if (duplicate) {
      throw new Error("Class with this name and grade level already exists for this teacher.");
    }
    const now = Date.now();
    const classId = await ctx.db.insert("classes", {
      teacherId: args.teacherId,
      name: capitalizeWords(args.name),
      gradeLevel: capitalizeWords(args.gradeLevel),
      academicYear: args.academicYear,
      createdAt: now,
    });
    return { id: classId, name: capitalizeWords(args.name) };
  },
});
