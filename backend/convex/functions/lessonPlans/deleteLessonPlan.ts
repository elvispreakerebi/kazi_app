import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const deleteLessonPlan = mutation({
  args: {
    teacherId: v.id("teachers"),
    lessonPlanId: v.id("lessonPlans"),
  },
  returns: v.object({
    ok: v.boolean(),
  }),
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) {
      throw new Error("Not authorized.");
    }
    
    const lessonPlan = await ctx.db.get(args.lessonPlanId);
    if (!lessonPlan || lessonPlan.teacherId !== args.teacherId) {
      throw new Error("Lesson plan not found or not owned.");
    }
    
    await ctx.db.delete(args.lessonPlanId);
    return { ok: true };
  },
});

