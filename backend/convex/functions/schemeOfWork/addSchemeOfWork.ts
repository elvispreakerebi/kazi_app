import { mutation } from "../../_generated/server";
import { v } from "convex/values";

export const addSchemeOfWork = mutation({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
    storageId: v.id("_storage"),
    currentWeek: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    const sowId = await ctx.db.insert("schemeOfWork", {
      teacherId: args.teacherId,
      subjectId: args.subjectId,
      storageId: args.storageId,
      uploadedAt: now,
      currentWeek: args.currentWeek,
      parsedContent: undefined,
      extractedTopics: undefined,
      progress: undefined,
    });
    return { id: sowId };
  },
});
