import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from '../../utils/text';

export const editSubject = mutation({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
    name: v.string(),
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) throw new Error("Not authorized.");
    const subjectDoc = await ctx.db.get(args.subjectId);
    if (!subjectDoc || subjectDoc.teacherId !== args.teacherId) throw new Error("Subject not found or not owned.");
    // Check for duplicate name in this class
    const newName = capitalizeWords(args.name);
    const existing = await ctx.db
      .query("subjects")
      .withIndex("by_classId", q => q.eq("classId", subjectDoc.classId))
      .collect();
    if (existing.find(s => s._id !== args.subjectId && s.name.trim().toLowerCase() === newName.toLowerCase())) {
      throw new Error(`Subject '${newName}' already exists for this class.`);
    }
    await ctx.db.patch(args.subjectId, { name: newName });
    return { ok: true };
  },
});
