import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const editLessonPlan = mutation({
  args: {
    teacherId: v.id("teachers"),
    lessonPlanId: v.id("lessonPlans"),
    title: v.optional(v.string()),
    content: v.optional(v.string()),
    objective: v.optional(v.string()),
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
    
    // Prepare updates
    const updates: Partial<{ title: string; content: any; objective?: string; updatedAt: number }> = {};
    if (args.title !== undefined) {
      updates.title = args.title;
    }
    if (args.content !== undefined) {
      updates.content = args.content;
    }
    if (args.objective !== undefined) {
      updates.objective = args.objective;
    }
    if (args.title !== undefined || args.content !== undefined || args.objective !== undefined) {
      updates.updatedAt = Date.now();
    }
    
    await ctx.db.patch(args.lessonPlanId, updates);
    return { ok: true };
  },
});

