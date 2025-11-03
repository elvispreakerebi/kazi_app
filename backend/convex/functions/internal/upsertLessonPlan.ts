import { internalMutation } from "../../_generated/server";
import { v } from "convex/values";

export const upsertLessonPlan = internalMutation({
  args: {
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    schemeId: v.optional(v.id("schemeOfWork")),
    title: v.string(),
    content: v.string(),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    status: v.union(
      v.literal('pending'),
      v.literal('in_progress'),
      v.literal('finished'),
    ),
    lessonDate: v.number(),
  },
  handler: async (ctx, args) => {
    const id = await ctx.db.insert("lessonPlans", args);
    return id;
  }
});
