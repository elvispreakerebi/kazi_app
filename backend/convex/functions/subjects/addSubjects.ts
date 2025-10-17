import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from '../../utils/text';

export const addSubjects = mutation({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
    subjects: v.array(
      v.object({
        name: v.string(),
      })
    ),
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) throw new Error("Not authorized.");
    const classDoc = await ctx.db.get(args.classId);
    if (!classDoc || classDoc.teacherId !== args.teacherId) throw new Error("Class not found or not owned by you.");
    // Get existing subjects for this class to dedupe
    const existing = await ctx.db
      .query("subjects")
      .withIndex("by_classId", q => q.eq("classId", args.classId))
      .collect();
    const lower = (s: string) => s.trim().toLowerCase();
    const results = [];
    for (const subj of args.subjects) {
      const subName = capitalizeWords(subj.name);
      const duplicate = existing.find(s => lower(s.name) === lower(subName));
      if (duplicate) {
        results.push({ error: `Subject '${subName}' already exists for this class.` });
        continue;
      }
      const now = Date.now();
      const subjectId = await ctx.db.insert("subjects", {
        classId: args.classId,
        teacherId: args.teacherId,
        name: subName,
        createdAt: now
      });
      results.push({ id: subjectId, name: subName });
      existing.push({
        _id: subjectId,
        _creationTime: now,
        name: subName,
        createdAt: now,
        teacherId: args.teacherId,
        classId: args.classId,
      }); // For deduping within-batch
    }
    return results;
  },
});
