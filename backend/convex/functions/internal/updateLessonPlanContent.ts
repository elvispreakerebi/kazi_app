import { internalMutation } from "../../_generated/server";
import { v } from "convex/values";

export const updateLessonPlanContent = internalMutation({
  args: {
    lessonPlanId: v.id("lessonPlans"),
    content: v.string(),
  },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.lessonPlanId, {
      content: args.content,
      updatedAt: Date.now(),
    });
    return { updated: true };
  },
});
