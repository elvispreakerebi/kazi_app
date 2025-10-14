import { mutation, query } from 'convex/server';
import { Id } from 'convex/values';

export const createLessonPlan = mutation(async ({ db }, {
  teacherId, subjectId, schemeId, title, content, language
}: {
  teacherId: Id<'teachers'>;
  subjectId: Id<'subjects'>;
  schemeId?: Id<'schemeOfWork'>;
  title: string;
  content: any;
  language: string;
}) => {
  const createdAt = Date.now();
  const lesson = await db.insert('lessonPlans', {
    teacherId, subjectId, schemeId, title, content, language, createdAt
  });
  return lesson;
});

export const listLessonPlans = query(async ({ db }, {
  subjectId
}: { subjectId: Id<'subjects'> }) => {
  return await db.query('lessonPlans').filter(q => q.eq(q.field('subjectId'), subjectId)).collect();
});

export const updateLessonPlan = mutation(async ({ db }, {
  lessonPlanId, title, content, language, status
}: {
  lessonPlanId: Id<'lessonPlans'>;
  title?: string;
  content?: any;
  language?: string;
  status?: string;
}) => {
  await db.patch('lessonPlans', lessonPlanId, { title, content, language, status, updatedAt: Date.now() });
  return await db.get('lessonPlans', lessonPlanId);
});

export const deleteLessonPlan = mutation(async ({ db }, {
  lessonPlanId
}: { lessonPlanId: Id<'lessonPlans'> }) => {
  await db.delete('lessonPlans', lessonPlanId);
  return { success: true };
});
