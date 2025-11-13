import { query } from "../../_generated/server";
import { v } from "convex/values";

export const getTeacherLessonPlans = query({
  args: {
    teacherId: v.id("teachers"),
  },
  returns: v.array(
    v.object({
      _id: v.id("lessonPlans"),
      _creationTime: v.number(),
      subjectId: v.id("subjects"),
      teacherId: v.id("teachers"),
      title: v.string(),
      content: v.any(),
      objective: v.optional(v.string()),
      createdAt: v.number(),
      updatedAt: v.optional(v.number()),
      subjectName: v.string(),
      classId: v.id("classes"),
      className: v.string(),
    })
  ),
  handler: async (ctx, args) => {
    // Get all lesson plans for the teacher
    const lessonPlans = await ctx.db
      .query("lessonPlans")
      .withIndex("by_teacherId", q => q.eq("teacherId", args.teacherId))
      .order("desc")
      .collect();
    
    // Fetch subject and class information for each lesson plan
    const lessonPlansWithSubjects = await Promise.all(
      lessonPlans.map(async (lp) => {
        const subject = await ctx.db.get(lp.subjectId);
        if (!subject) {
          return {
            ...lp,
            subjectName: '',
            classId: '' as any,
            className: '',
          };
        }
        
        const classDoc = await ctx.db.get(subject.classId);
        
        return {
          ...lp,
          subjectName: subject.name ?? '',
          classId: subject.classId,
          className: classDoc?.name ?? classDoc?.gradeLevel ?? '',
        };
      })
    );
    
    return lessonPlansWithSubjects;
  },
});

