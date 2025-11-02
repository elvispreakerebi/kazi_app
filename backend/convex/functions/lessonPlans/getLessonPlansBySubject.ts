import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getLessonPlansBySubject = query({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
  },
  returns: v.array(
    v.object({
      _id: v.id("lessonPlans"),
      _creationTime: v.number(),
      subjectId: v.id("subjects"),
      teacherId: v.id("teachers"),
      title: v.string(),
      content: v.any(),
      objective: v.optional(v.string()),
      createdAt: v.number(),
      updatedAt: v.optional(v.number()),
    })
  ),
  handler: async (ctx, args) => {
    // Verify subject belongs to teacher
    const subject = await ctx.db.get(args.subjectId);
    if (!subject || subject.teacherId !== args.teacherId) {
      throw new Error("Subject not found or not owned by teacher");
    }

    // Get all lesson plans for the subject
    const lessonPlans = await ctx.db
      .query("lessonPlans")
      .withIndex("by_subjectId", q => q.eq("subjectId", args.subjectId))
      .collect();
    
    return lessonPlans;
  },
});

