import { mutation } from "../../_generated/server";
import { v } from "convex/values";
import { capitalizeWords } from '../../utils/text';

export const addClass = mutation({
  args: {
    teacherId: v.id("teachers"),
    classes: v.array(
      v.object({
        name: v.string(),
        gradeLevel: v.string(),
        academicYear: v.optional(v.string()),
      })
    ),
  },
  handler: async (ctx, args) => {
    // Fetch teacher and check verified
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher) throw new Error("Teacher not found.");
    if (!teacher.verified) throw new Error("Account must be verified to add a class.");
    // Get existing classes to check for duplicates (case insensitive)
    const existing = await ctx.db
      .query("classes")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .collect();
    const lower = (s: string) => s.trim().toLowerCase();
    // Prepare results for each item
    const results = [];
    for (const cls of args.classes) {
      const className = capitalizeWords(cls.name);
      const grade = capitalizeWords(cls.gradeLevel);
      const duplicate = existing.find(
        c => lower(c.name) === lower(className) && lower(c.gradeLevel) === lower(grade)
      );
      if (duplicate) {
        results.push({ error: `Class '${className}' (${grade}) already exists.` });
        continue;
      }
      const now = Date.now();
      const classId = await ctx.db.insert("classes", {
        teacherId: args.teacherId,
        name: className,
        gradeLevel: grade,
        academicYear: cls.academicYear,
        createdAt: now,
      });
      results.push({ id: classId, name: className, gradeLevel: grade });
      // Optionally: update 'existing' to prevent further cross-collisions in this batch
      existing.push({
        _id: classId,
        _creationTime: now,
        teacherId: args.teacherId,
        name: className,
        gradeLevel: grade,
        academicYear: cls.academicYear,
        createdAt: now,
      });
    }
    return results;
  },
});
