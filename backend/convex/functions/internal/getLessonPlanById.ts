import { internalQuery } from "../../_generated/server";
import { v } from "convex/values";

export const getLessonPlanById = internalQuery({
  args: { lessonPlanId: v.id("lessonPlans") },
  handler: async (ctx, args) => {
    const plan = await ctx.db.get(args.lessonPlanId);
    return plan || null;
  },
});
