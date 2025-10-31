import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getClass = query({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
  },
  handler: async (ctx, args) => {
    const classDoc = await ctx.db.get(args.classId);
    if (!classDoc || classDoc.teacherId !== args.teacherId) {
      throw new Error("Class not found or not owned.");
    }
    return classDoc;
  },
});
