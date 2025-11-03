import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getTopicsBySubject = query({
  args: {
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
  },
  returns: v.array(
    v.object({
      topic: v.string(),
      week: v.optional(v.number()),
    })
  ),
  handler: async (ctx, args) => {
    const sow = await ctx.db
      .query("schemeOfWork")
      .withIndex("by_subjectId", q => q.eq("subjectId", args.subjectId))
      .filter(q => q.eq(q.field("teacherId"), args.teacherId))
      .first();
    if (!sow || !Array.isArray(sow.extractedTopics) || sow.extractedTopics.length === 0) {
      return [];
    }
    // Only return topic and week
    return sow.extractedTopics.map(({ topic, week }) => ({ topic, week }));
  },
});
