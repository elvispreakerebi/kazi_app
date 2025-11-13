import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const createLessonPlan = mutation({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
    title: v.string(),
    content: v.string(),
    objective: v.optional(v.string()),
  },
  returns: v.object({
    _id: v.id("lessonPlans"),
    _creationTime: v.number(),
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    title: v.string(),
    content: v.string(),
    objective: v.optional(v.string()),
    createdAt: v.number(),
  }),
  handler: async (ctx, args) => {
    // Verify subject belongs to teacher
    const subject = await ctx.db.get(args.subjectId);
    if (!subject || subject.teacherId !== args.teacherId) {
      throw new Error("Subject not found or not owned by teacher");
    }

    const now = Date.now();
    const lessonPlanId = await ctx.db.insert("lessonPlans", {
      subjectId: args.subjectId,
      teacherId: args.teacherId,
      title: args.title,
      content: args.content,
      objective: args.objective,
      createdAt: now,
    });

    const lessonPlan = await ctx.db.get(lessonPlanId);
    if (!lessonPlan) {
      throw new Error("Failed to create lesson plan");
    }

    return {
      _id: lessonPlan._id,
      _creationTime: lessonPlan._creationTime,
      subjectId: lessonPlan.subjectId,
      teacherId: lessonPlan.teacherId,
      title: lessonPlan.title,
      content: lessonPlan.content as string,
      objective: lessonPlan.objective,
      createdAt: lessonPlan.createdAt,
    };
  },
});


