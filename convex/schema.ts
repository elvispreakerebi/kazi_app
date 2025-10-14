// Convex schema for Kazi backend: Teachers, Classes, Subjects, Curriculum, Schemes, LessonPlans
import { v } from 'convex/values';

export default {
  teachers: {
    // Primary info
    id: v.id(),
    email: v.string(),
    passwordHash: v.optional(v.string()), // For email/pass auth
    googleId: v.optional(v.string()), // For Google auth linkage
    name: v.optional(v.string()),
    createdAt: v.number(),
    // For extensibility (last login, etc.):
    lastLogin: v.optional(v.number()),
  },
  classes: {
    id: v.id(),
    teacherId: v.id(), // references teachers
    name: v.string(),
    academicYear: v.optional(v.string()),
    curriculumId: v.optional(v.id()), // references curriculum
    createdAt: v.number(),
  },
  subjects: {
    id: v.id(),
    classId: v.id(), // references classes
    name: v.string(),
    // relations for easier subject-by-teacher, etc.:
    teacherId: v.id(),
    createdAt: v.number(),
  },
  curriculum: {
    id: v.id(),
    teacherId: v.id(),
    name: v.string(),
    description: v.optional(v.string()),
    createdAt: v.number(),
    fileId: v.optional(v.id()), // uploaded curriculum file
  },
  schemeOfWork: {
    id: v.id(),
    subjectId: v.id(),
    teacherId: v.id(),
    fileId: v.optional(v.id()), // uploaded scheme file
    parsedContent: v.optional(v.any()), // structured
    uploadedAt: v.number(),
  },
  lessonPlans: {
    id: v.id(),
    subjectId: v.id(),
    teacherId: v.id(),
    schemeId: v.optional(v.id()),
    title: v.string(),
    content: v.any(), // structured AI output or edited
    language: v.string(), // e.g. 'en','fr','rw'
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    status: v.optional(v.string()), // draft/completed, etc.
  },
  files: {
    id: v.id(),
    ownerId: v.id(), // teacher
    path: v.string(),
    type: v.string(), // 'curriculum' | 'scheme' | ...
    uploadedAt: v.number(),
  }
}
