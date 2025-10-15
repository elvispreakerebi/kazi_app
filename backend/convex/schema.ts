// NOTE: You can remove this file. Declaring the shape
// of the database is entirely optional in Convex.
// See https://docs.convex.dev/database/schemas.

import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  teachers: defineTable({
    email: v.string(),
    passwordHash: v.optional(v.string()),    // For email/password auth
    googleId: v.optional(v.string()),        // For Google auth
    name: v.optional(v.string()),
    createdAt: v.number(),
    lastLogin: v.optional(v.number()),
    language: v.string(), // 'english' | 'french' | 'kiryanwanda' (default: 'english')
  }).index("by_email", ["email"])
    .index("by_googleId", ["googleId"]),

  classes: defineTable({
    teacherId: v.id("teachers"),
    name: v.string(),
    gradeLevel: v.string(), // Added: each class has a grade level
    academicYear: v.optional(v.string()),
    createdAt: v.number(),
  }).index("by_teacherId", ["teacherId"]),

  subjects: defineTable({
    classId: v.id("classes"),
    teacherId: v.id("teachers"),
    name: v.string(),
    createdAt: v.number(),
  }).index("by_classId", ["classId"])
    .index("by_teacherId", ["teacherId"]),

  curriculum: defineTable({
    teacherId: v.id("teachers"),
    name: v.string(),
    createdAt: v.number(),
    fileId: v.optional(v.id("files")), // Uploaded curriculum file
    parsedContent: v.optional(v.any()), // Added: structured/parsed curriculum content
  }).index("by_teacherId", ["teacherId"]),

  schemeOfWork: defineTable({
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    fileId: v.optional(v.id("files")), // Uploaded scheme file
    parsedContent: v.optional(v.any()), // e.g. extracted topics/structure
    uploadedAt: v.number(),
  }).index("by_subjectId", ["subjectId"])
    .index("by_teacherId", ["teacherId"]),

  lessonPlans: defineTable({
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    schemeId: v.optional(v.id("schemeOfWork")),
    title: v.string(),
    content: v.any(),       // structured lesson plan
    language: v.string(),   // 'en', 'fr', 'rw', etc.
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    status: v.optional(v.string()), // draft, complete, etc.
  }).index("by_subjectId", ["subjectId"])
    .index("by_teacherId", ["teacherId"]),

  files: defineTable({
    ownerId: v.id("teachers"),
    path: v.string(), // File storage path or key
    type: v.string(), // e.g. 'curriculum' | 'scheme'
    uploadedAt: v.number(),
  }).index("by_ownerId", ["ownerId"])
});
