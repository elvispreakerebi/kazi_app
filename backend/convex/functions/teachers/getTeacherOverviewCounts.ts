import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getTeacherOverviewCounts = query({
  args: { teacherId: v.id("teachers") },
  returns: v.object({
    classes: v.number(),
    subjects: v.number(),
    lessonPlans: v.number(),
  }),
  handler: async (ctx, args) => {
    const classesCount = (await ctx.db
      .query("classes")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .collect()).length;
    const subjectsCount = (await ctx.db
      .query("subjects")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .collect()).length;
    const lessonPlansCount = (await ctx.db
      .query("lessonPlans")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .collect()).length;
    return {
      classes: classesCount,
      subjects: subjectsCount,
      lessonPlans: lessonPlansCount,
    };
  },
});