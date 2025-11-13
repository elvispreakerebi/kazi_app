import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const createLessonPlanHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }

  let body;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }

  const { classId, subjectId, topic, objective } = body;

  if (!classId || !subjectId || !topic) {
    return new Response(JSON.stringify({ error: "Missing required fields: classId, subjectId, and topic are required." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }

  try {
    const lessonPlan = await ctx.runAction(api.functions.lessonPlans.generateLessonPlanAction.generateLessonPlanAction, {
      teacherId: verify.teacherId as Id<"teachers">,
      classId: classId as Id<"classes">,
      subjectId: subjectId as Id<"subjects">,
      topic: topic as string,
      objective: objective as string | undefined,
    });
    return new Response(JSON.stringify(lessonPlan), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};

