import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getCurriculumContext = query({
  args: { teacherId: v.id("teachers") },
  returns: v.union(v.string(), v.null()),
  handler: async (ctx, args) => {
    const curriculum = await ctx.db
      .query("curriculum")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .first();
    return curriculum?.parsedContent || null;
  },
});
