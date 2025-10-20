import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getClassSubjectsCount = query({
  args: {
    classId: v.id("classes"),
    teacherId: v.id("teachers"),
  },
  returns: v.object({ count: v.number() }),
  handler: async (ctx, args) => {
    const count = (await ctx.db
      .query("subjects")
      .withIndex("by_classId", q => q.eq("classId", args.classId))
      .filter(q => q.eq(q.field("teacherId"), args.teacherId))
      .collect()).length;
    return { count };
  },
});
