import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const addCurriculum = mutation({
  args: {
    teacherId: v.id("teachers"),
    fileId: v.id("files"),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    // Find if teacher already has a curriculum file
    const existing = await ctx.db
      .query("curriculum")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .first();
    if (existing) {
      // Update existing row (replace file)
      await ctx.db.patch(existing._id, {
        fileId: args.fileId,
        createdAt: now,
      });
      return { id: existing._id, updated: true };
    } else {
      // Add new
      const id = await ctx.db.insert("curriculum", {
        teacherId: args.teacherId,
        fileId: args.fileId,
        createdAt: now,
        parsedContent: undefined,
      });
      return { id, created: true };
    }
  },
});
