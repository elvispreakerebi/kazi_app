// NOTE: You can remove this file. Declaring the shape
// of the database is entirely optional in Convex.
// See https://docs.convex.dev/database/schemas.

import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";
import { authTables } from "@convex-dev/auth/server";

export default defineSchema({
  ...authTables,
  users: defineTable({
    // Basic/profile fields
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
    // Other fields from previous teachers table can go here
  }).index("by_email", ["email"])
    .index("by_googleId", ["googleId"]),

  classes: defineTable({
    userId: v.id("users"),
    name: v.string(),
    gradeLevel: v.string(),
    academicYear: v.optional(v.string()),
    createdAt: v.number(),
  }).index("by_userId", ["userId"]),

  subjects: defineTable({
    classId: v.id("classes"),
    userId: v.id("users"),
    name: v.string(),
    createdAt: v.number(),
  }).index("by_classId", ["classId"])
    .index("by_userId", ["userId"]),

  curriculum: defineTable({
    userId: v.id("users"),
    name: v.string(),
    createdAt: v.number(),
    fileId: v.optional(v.id("files")),
    parsedContent: v.optional(v.any()),
  }).index("by_userId", ["userId"]),

  schemeOfWork: defineTable({
    subjectId: v.id("subjects"),
    userId: v.id("users"),
    fileId: v.optional(v.id("files")),
    parsedContent: v.optional(v.any()),
    uploadedAt: v.number(),
  }).index("by_subjectId", ["subjectId"])
    .index("by_userId", ["userId"]),

  lessonPlans: defineTable({
    subjectId: v.id("subjects"),
    userId: v.id("users"),
    schemeId: v.optional(v.id("schemeOfWork")),
    title: v.string(),
    content: v.any(),
    createdAt: v.number(),
    updatedAt: v.optional(v.number()),
    status: v.optional(v.string()),
  }).index("by_subjectId", ["subjectId"])
    .index("by_userId", ["userId"]),

  files: defineTable({
    ownerId: v.id("users"),
    path: v.string(),
    type: v.string(),
    uploadedAt: v.number(),
  }).index("by_ownerId", ["ownerId"]),
});
