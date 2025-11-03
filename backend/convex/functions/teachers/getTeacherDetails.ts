import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getTeacherDetails = query({
  args: { teacherId: v.id("teachers") },
  handler: async (ctx, args) => {
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher) return null;
    // Restrict which fields are returned
    return {
      email: teacher.email,
      name: teacher.name,
      language: teacher.language,
      verified: teacher.verified
    };
  },
});
