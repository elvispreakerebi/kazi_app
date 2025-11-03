import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from '../../utils/text';

export const editClass = mutation({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
    name: v.optional(v.string()),
    gradeLevel: v.optional(v.string()),
    academicYear: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) throw new Error("Not authorized.");
    const classDoc = await ctx.db.get(args.classId);
    if (!classDoc || classDoc.teacherId !== args.teacherId) throw new Error("Class not found or not owned.");
    // Use an explicit type for updates
    const updates: Partial<{ name: string; gradeLevel: string; academicYear?: string }> = {};
    if (args.name) updates.name = capitalizeWords(args.name);
    if (args.gradeLevel) updates.gradeLevel = capitalizeWords(args.gradeLevel);
    if (args.academicYear) updates.academicYear = args.academicYear;
    await ctx.db.patch(args.classId, updates);
    return { ok: true };
  },
});
