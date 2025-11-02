"use node";

import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { Dedalus } from "dedalus-labs";
import type { Id } from "../../_generated/dataModel";

export const generateLessonPlanAction = action({
  args: {
    teacherId: v.id("teachers"),
    classId: v.id("classes"),
    subjectId: v.id("subjects"),
    topic: v.string(),
  },
  returns: v.object({
    _id: v.id("lessonPlans"),
    _creationTime: v.number(),
    subjectId: v.id("subjects"),
    teacherId: v.id("teachers"),
    title: v.string(),
    content: v.string(),
    createdAt: v.number(),
  }),
  handler: async (ctx, args) => {
    // Fetch class and subject details
    const classDoc = await ctx.runQuery(api.functions.classes.getClass.getClass, {
      teacherId: args.teacherId,
      classId: args.classId,
    }) as {
      _id: Id<"classes">;
      _creationTime: number;
      teacherId: Id<"teachers">;
      name: string;
      gradeLevel: string;
      academicYear?: string;
      createdAt: number;
    };
    
    const subjectDoc = await ctx.runQuery(api.functions.subjects.getSubjectById.getSubjectById, {
      teacherId: args.teacherId,
      subjectId: args.subjectId,
    }) as {
      _id: Id<"subjects">;
      _creationTime: number;
      classId: Id<"classes">;
      teacherId: Id<"teachers">;
      name: string;
      createdAt: number;
    };

    const className: string = classDoc.name || classDoc.gradeLevel || "(not specified)";
    const subjectName: string = subjectDoc.name || "(not specified)";

    // Build prompt for Dedalus Labs
    const prompt: string = [
      "You are an expert lesson plan generator for African primary schools, specifically for Rwanda.",
      "Generate a comprehensive, clear, and actionable lesson plan for the following:",
      `Class: ${className}`,
      `Subject: ${subjectName}`,
      `Topic: ${args.topic}`,
      "",
      "Generate a plan with these sections:",
      "1. Lesson Title (Topic)",
      "2. Lesson Type (e.g. New Concept, Review, Practical)",
      "3. Duration (minutes)",
      "4. Lesson Objectives (use at least 2-3, aligned to curriculum)",
      "5. Lesson Introduction (story, question, warmup)",
      "6. Step-by-step Lesson Activities (number/list the steps clearly for teacher guidance, use African context examples if possible)",
      "7. Teaching Aids (physical or digital aids, e.g. flashcards, picture cards, blackboard)",
      "8. Assessment (how will the teacher check understanding; include at least 1 activity)",
      "9. Extensions or Remediation (optional, for fast or struggling learners)",
      "10. AI Assistant Suggestions (offer 1-2 quick ideas for teacher support: e.g. differentiation tip, engagement boost)",
      "",
      "Always make your output teacher-friendly, locally relevant to Rwanda, and efficient for the classroom. Use clear formatting.",
      "Return the sections as a Markdown-formatted string.",
    ].join("\n");

    // Generate lesson plan using Dedalus Labs with streaming
    const client = new Dedalus();

    const stream = await client.chat.create({
      model: "openai/gpt-4.1",
      input: [
        {
          role: "user",
          content: prompt,
        },
      ],
      mcp_servers: ["windsor/brave-search-mcp"],
      stream: true,
    });

    // Accumulate streaming content
    let lessonPlanContent: string = "";
    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content || "";
      if (content) {
        lessonPlanContent += content;
      }
    }

    if (!lessonPlanContent) {
      throw new Error("Failed to generate lesson plan content");
    }

    // Save lesson plan to database
    const lessonPlan = await ctx.runMutation(api.functions.lessonPlans.createLessonPlan.createLessonPlan, {
      teacherId: args.teacherId,
      subjectId: args.subjectId,
      title: args.topic,
      content: lessonPlanContent,
    }) as {
      _id: Id<"lessonPlans">;
      _creationTime: number;
      subjectId: Id<"subjects">;
      teacherId: Id<"teachers">;
      title: string;
      content: string;
      createdAt: number;
    };

    return lessonPlan;
  },
});

