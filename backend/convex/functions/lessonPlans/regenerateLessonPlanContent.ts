"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { openai } from '@ai-sdk/openai';
import { streamObject } from 'ai';
import { z, ZodObject } from 'zod';

export const regenerateLessonPlanContent = action({
  args: {
    lessonPlanId: v.id("lessonPlans"),
    teacherId: v.id("teachers"),
    subjectId: v.optional(v.id("subjects")),
    weekObj: v.optional(v.object({ topic: v.string(), week: v.optional(v.number()) })),
    classId: v.optional(v.id("classes")),
    lessonDate: v.optional(v.number()),
  },
  handler: async (ctx, args): Promise<{ content: string; title?: string; objectives?: string[] }> => {
    // Get the lesson plan — use internal query, not ctx.db.get
    // @ts-expect-error Convex codegen workaround
    const plan = await ctx.runQuery(api.functions.internal.getLessonPlanById, { lessonPlanId: args.lessonPlanId });
    if (!plan || plan.teacherId !== args.teacherId) throw new Error("Lesson plan not found or not owned.");
    const subjectId = args.subjectId || plan.subjectId;
    // @ts-expect-error Convex codegen workaround
    const schemeContent = await ctx.runQuery(api.functions.schemeOfWork.getSchemeOfWorkContext, {
      subjectId,
      teacherId: args.teacherId,
    });
    // @ts-expect-error Convex codegen workaround
    const curriculumContent = await ctx.runQuery(api.functions.curriculum.getCurriculumContext, {
      teacherId: args.teacherId,
    });
    const weekObj = args.weekObj || (plan as any).weekObj || { topic: plan.title, week: undefined };
    const classId = args.classId || (plan as any).classId || undefined;
    const lessonDate = args.lessonDate || (plan as any).lessonDate || undefined;
    const prompt: string = [
      "You are an expert lesson plan generator for African primary schools.",
      "Regenerate a comprehensive, clear, and actionable lesson plan for the following:",
      `Class: ${classId || "(not specified)"}`,
      `SubjectId: [${subjectId}]`,
      `Week: ${weekObj.week ?? "(not specified)"}`,
      `Topic: ${weekObj.topic}`,
      `Lesson date (YYYY-MM-DD): ${lessonDate ? new Date(lessonDate).toLocaleDateString("en-CA") : "(not specified)"}`,
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
    // Update lesson plan content via internal mutation, not ctx.db.patch
    // @ts-expect-error Convex codegen workaround
    await ctx.runMutation(api.functions.internal.updateLessonPlanContent, {
      lessonPlanId: args.lessonPlanId,
      content,
    });
    return { content, title, objectives };
  },
});
