// NOTE: You can remove this file. Declaring the shape
// of the database is entirely optional in Convex.
// See https://docs.convex.dev/database/schemas.

import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  teachers: defineTable({
    email: v.string(),
    name: v.optional(v.string()),
    createdAt: v.number(),
    lastLogin: v.optional(v.number()),
    language: v.union(
      v.literal("english"),
      v.literal("french"),
      v.literal("kiryanwanda")
    ),
    googleId: v.optional(v.string()),
    hashedPassword: v.optional(v.string()),
    // Add more teacher metadata fields here if desired
  })
    .index("by_email", ["email"])
    .index("by_googleId", ["googleId"]),

  classes: defineTable({
    teacherId: v.id("teachers"),
    name: v.string(),
    gradeLevel: v.string(),
    academicYear: v.optional(v.string()),
    createdAt: v.number(),
  }).index("by_teacherId", ["teacherId"]),

  subjects: defineTable({
    classId: v.id("classes"),
    teacherId: v.id("teachers"),
    name: v.string(),
    createdAt: v.number(),
  })
    .index("by_classId", ["classId"])
    .index("by_teacherId", ["teacherId"]),

  curriculum: defineTable({
    teacherId: v.id("teachers"),
    name: v.string(),
    createdAt: v.number(),
    fileId: v.optional(v.id("files")),
    parsedContent: v.optional(v.any()),
  }).index("by_teacherId", ["teacherId"]),

  schemeOfWork: defineTable({
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    fileId: v.optional(v.id("files")),
    parsedContent: v.optional(v.any()),
    uploadedAt: v.number(),
  })
    .index("by_subjectId", ["subjectId"])
    .index("by_teacherId", ["teacherId"]),

  lessonPlans: defineTable({
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    schemeId: v.optional(v.id("schemeOfWork")),
    title: v.string(),
    content: v.any(),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    status: v.optional(v.string()),
  })
    .index("by_subjectId", ["subjectId"])
    .index("by_teacherId", ["teacherId"]),

  files: defineTable({
    ownerId: v.id("teachers"),
    path: v.string(),
    type: v.string(),
    uploadedAt: v.number(),
  }).index("by_ownerId", ["ownerId"]),
});
