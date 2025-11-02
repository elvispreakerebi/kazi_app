import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getLessonPlan = query({
  args: {
    teacherId: v.id("teachers"),
    lessonPlanId: v.id("lessonPlans"),
  },
  returns: v.object({
    _id: v.id("lessonPlans"),
    _creationTime: v.number(),
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    title: v.string(),
    content: v.any(),
    objective: v.optional(v.string()),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    subjectName: v.string(),
    className: v.string(),
  }),
  handler: async (ctx, args) => {
    const lessonPlan = await ctx.db.get(args.lessonPlanId);
    if (!lessonPlan || lessonPlan.teacherId !== args.teacherId) {
      throw new Error("Lesson plan not found or not owned.");
    }
    
    // Fetch subject information
    const subject = await ctx.db.get(lessonPlan.subjectId);
    if (!subject) {
      throw new Error("Subject not found");
    }
    
    // Fetch class information
    const classDoc = await ctx.db.get(subject.classId);
    
    return {
      _id: lessonPlan._id,
      _creationTime: lessonPlan._creationTime,
      subjectId: lessonPlan.subjectId,
      teacherId: lessonPlan.teacherId,
      title: lessonPlan.title,
      content: lessonPlan.content,
      objective: lessonPlan.objective,
      createdAt: lessonPlan.createdAt,
      updatedAt: lessonPlan.updatedAt,
      subjectName: subject.name ?? '',
      className: classDoc?.name ?? classDoc?.gradeLevel ?? '',
    };
  },
});

