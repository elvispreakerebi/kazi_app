import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const deleteClass = mutation({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) throw new Error("Not authorized.");
    const classDoc = await ctx.db.get(args.classId);
    if (!classDoc || classDoc.teacherId !== args.teacherId) throw new Error("Class not found or not owned.");
    await ctx.db.delete(args.classId);
    return { ok: true };
  },
});
