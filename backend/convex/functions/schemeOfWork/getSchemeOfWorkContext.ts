import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getSchemeOfWorkContext = query({
  args: {
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
  },
  returns: v.union(v.string(), v.null()),
  handler: async (ctx, args) => {
    const sow = await ctx.db
      .query("schemeOfWork")
      .withIndex("by_subjectId", q => q.eq("subjectId", args.subjectId))
      .filter(q => q.eq(q.field("teacherId"), args.teacherId))
      .first();
    return sow?.parsedContent || null;
  },
});
