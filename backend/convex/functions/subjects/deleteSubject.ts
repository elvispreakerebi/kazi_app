import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const deleteSubject = mutation({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
  },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher || !teacher.verified) throw new Error("Not authorized.");
    const subjectDoc = await ctx.db.get(args.subjectId);
    if (!subjectDoc || subjectDoc.teacherId !== args.teacherId) throw new Error("Subject not found or not owned.");
    await ctx.db.delete(args.subjectId);
    return { ok: true };
  },
});
