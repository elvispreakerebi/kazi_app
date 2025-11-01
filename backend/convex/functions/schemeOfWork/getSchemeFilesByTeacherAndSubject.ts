import { query } from '../../_generated/server';
import { v } from 'convex/values';

export const getSchemeFilesByTeacherAndSubject = query({
  args: {
    teacherId: v.id('teachers'),
    subjectId: v.id('subjects')
  },
  returns: v.array(
    v.object({
      _id: v.id('schemeOfWork'),
      subjectId: v.id('subjects'),
      teacherId: v.id('teachers'),
      storageId: v.id('_storage'),
      uploadedAt: v.number(),
      currentWeek: v.optional(v.number()),
      parsedContent: v.optional(v.any()),
      progress: v.optional(v.object({topicsCovered: v.number(), totalTopics: v.number()})),
      fileName: v.optional(v.string()),
      extractedTopics: v.optional(
        v.array(
          v.object({topic: v.string(), week: v.optional(v.number())})
        )
      )
    })
  ),
  handler: async (ctx, args) => {
    // Get all SOWs for this subject + teacher, ordered newest first
    const sowDocs = await ctx.db
      .query('schemeOfWork')
      .withIndex('by_subjectId', (q) => q.eq('subjectId', args.subjectId))
      .order('desc')
      .collect();
    return sowDocs.filter(doc => doc.teacherId === args.teacherId);
  },
});
