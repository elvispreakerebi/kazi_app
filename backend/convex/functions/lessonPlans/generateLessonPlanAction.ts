"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { openai } from '@ai-sdk/openai';
import { streamObject } from 'ai';
import { z, ZodObject } from 'zod';

export const generateLessonPlanAction = action({
  args: {
    teacherId: v.id("teachers"),
    subjectId: v.id("subjects"),
    weekObj: v.object({ topic: v.string(), week: v.optional(v.number()) }),
    lessonDate: v.number(),
    classId: v.optional(v.id("classes")),
  },
  handler: async (ctx, args): Promise<{ lessonPlanId: string; lessonPlan: { content: string; title?: string; objectives?: string[] } }> => {
    // Convex generated types sometimes lag - use ts-expect-error for now if your editor shows red underline
    // If you run `npx convex dev` and restart your IDE, these errors can usually be removed.
    // @ts-expect-error Convex function typing workaround
    const schemeContent = await ctx.runQuery(api.functions.schemeOfWork.getSchemeOfWorkContext, {
      subjectId: args.subjectId,
      teacherId: args.teacherId,
    });
    // @ts-expect-error Convex function typing workaround
    const curriculumContent = await ctx.runQuery(api.functions.curriculum.getCurriculumContext, {
      teacherId: args.teacherId,
    });

    const prompt: string = [
      "You are an expert lesson plan generator for African primary schools.",
      "Generate a comprehensive, clear, and actionable lesson plan for the following:",
      `Class: ${args.classId || "(not specified)"}`,
      `SubjectId: [${args.subjectId}]`,
      `Week: ${args.weekObj.week ?? "(not specified)"}`,
      `Topic: ${args.weekObj.topic}`,
      `Lesson date (YYYY-MM-DD): ${new Date(args.lessonDate).toLocaleDateString("en-CA")}`,
      "",
      "Use the following (if present) for guidance/context.",
      `Scheme of Work: ${schemeContent ? `\n${schemeContent}` : "(not available)"}`,
      `Curriculum: ${curriculumContent ? `\n${curriculumContent}` : "(not available)"}`,
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
      "Always make your output teacher-friendly, locally relevant, and efficient for the classroom. Use clear formatting.",
      "Return the sections as a Markdown-formatted string.",
    ].join("\n");

    const schema: ZodObject<any> = z.object({
      content: z.string(),
      title: z.string().optional(),
      objectives: z.array(z.string()).optional(),
    });
    const model = openai('gpt-4o');
    const { partialObjectStream } = streamObject({
      model,
      prompt,
      schema,
    });
    let content = '';
    let title: string | undefined = undefined;
    let objectives: string[] | undefined = undefined;
    for await (const partial of partialObjectStream) {
      if (typeof partial.content === 'string') content = partial.content;
      if (typeof partial.title === 'string') title = partial.title;
      if (Array.isArray(partial.objectives)) objectives = partial.objectives;
    }
    // @ts-expect-error Convex internal function typing workaround
    const insertedId: string = await ctx.runMutation(api.functions.internal.upsertLessonPlan, {
      subjectId: args.subjectId,
      teacherId: args.teacherId,
      schemeId: undefined,
      title: title || args.weekObj.topic,
      content,
      createdAt: Date.now(),
      updatedAt: undefined,
      status: "pending",
      lessonDate: args.lessonDate,
    });
    return { lessonPlanId: insertedId, lessonPlan: { content, title, objectives } };
  },
});