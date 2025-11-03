import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getTeacherClasses = query({
  args: {
    teacherId: v.id("teachers"),
  },
  handler: async (ctx, args) => {
    const classes = await ctx.db
      .query("classes")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .order("asc")
      .collect();
    return classes;
  },
});
