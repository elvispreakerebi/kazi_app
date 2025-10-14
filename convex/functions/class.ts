import { mutation, query } from 'convex/server';
import { Id } from 'convex/values';

// --- Classes ---
export const createClass = mutation(async ({ db }, {
  teacherId, name, academicYear, curriculumId
}: { teacherId: Id<'teachers'>, name: string, academicYear?: string, curriculumId?: Id<'curriculum'> }) => {
  const createdAt = Date.now();
  const cls = await db.insert('classes', { teacherId, name, academicYear, curriculumId, createdAt });
  return cls;
});

export const listClasses = query(async ({ db }, {
  teacherId
}: { teacherId: Id<'teachers'> }) => {
  return await db.query('classes').filter(q => q.eq(q.field('teacherId'), teacherId)).collect();
});

export const updateClass = mutation(async ({ db }, {
  classId, name, academicYear, curriculumId
}: { classId: Id<'classes'>, name?: string, academicYear?: string, curriculumId?: Id<'curriculum'> }) => {
  // Redirect/test owner in real prod
  await db.patch('classes', classId, { name, academicYear, curriculumId });
  return await db.get('classes', classId);
});

export const deleteClass = mutation(async ({ db }, {
  classId
}: { classId: Id<'classes'> }) => {
  // Stub: Should check teacher owns class!
  await db.delete('classes', classId);
  return { success: true };
});

// --- Subjects ---
export const createSubject = mutation(async ({ db }, {
  classId, teacherId, name
}: { classId: Id<'classes'>, teacherId: Id<'teachers'>, name: string }) => {
  const createdAt = Date.now();
  const subj = await db.insert('subjects', { classId, teacherId, name, createdAt });
  return subj;
});

export const listSubjects = query(async ({ db }, {
  classId
}: { classId: Id<'classes'> }) => {
  return await db.query('subjects').filter(q => q.eq(q.field('classId'), classId)).collect();
});

export const updateSubject = mutation(async ({ db }, {
  subjectId, name
}: { subjectId: Id<'subjects'>, name?: string }) => {
  await db.patch('subjects', subjectId, { name });
  return await db.get('subjects', subjectId);
});

export const deleteSubject = mutation(async ({ db }, {
  subjectId
}: { subjectId: Id<'subjects'> }) => {
  await db.delete('subjects', subjectId);
  return { success: true };
});
