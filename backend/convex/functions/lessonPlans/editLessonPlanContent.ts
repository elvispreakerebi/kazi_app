import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const editLessonPlanContent = mutation({
  args: {
    lessonPlanId: v.id("lessonPlans"),
    teacherId: v.id("teachers"),
    content: v.string(),
  },
  handler: async (ctx, args) => {
    const plan = await ctx.db.get(args.lessonPlanId);
    if (!plan || plan.teacherId !== args.teacherId) {
      throw new Error("Lesson plan not found or not owned by this teacher.");
    }
    await ctx.db.patch(args.lessonPlanId, {
      content: args.content,
      updatedAt: Date.now(),
    });
    return { updated: true };
  },
});
