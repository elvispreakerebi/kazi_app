import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getSubjectById = query({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
  },
  returns: v.object({
    _id: v.id("subjects"),
    _creationTime: v.number(),
    classId: v.id("classes"),
    teacherId: v.id("teachers"),
    name: v.string(),
    createdAt: v.number(),
  }),
  handler: async (ctx, args) => {
    const subject = await ctx.db.get(args.subjectId);
    if (!subject || subject.teacherId !== args.teacherId) {
      throw new Error("Subject not found or not owned by teacher");
    }
    return subject;
  },
});

