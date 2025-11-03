import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getClassSubjects = query({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
  },
  handler: async (ctx, args) => {
    // Only subjects where both teacherId and classId match
    const subjects = await ctx.db
      .query("subjects")
      .withIndex("by_classId", q => q.eq("classId", args.classId))
      .collect();
    // Cross-check teacher
    return subjects.filter((s) => s.teacherId === args.teacherId);
  },
});
