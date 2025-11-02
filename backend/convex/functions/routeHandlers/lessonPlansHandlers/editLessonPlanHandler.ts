import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const editLessonPlanHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  
  let lessonPlanId, title, content;
  try {
    const body = await req.json();
    ({ lessonPlanId, title, content } = body);
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  
  if (!lessonPlanId) {
    return new Response(JSON.stringify({ error: "lessonPlanId is required." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  
  try {
    const result = await ctx.runMutation(api.functions.lessonPlans.editLessonPlan.editLessonPlan, {
      teacherId: verify.teacherId as Id<"teachers">,
      lessonPlanId: lessonPlanId as Id<"lessonPlans">,
      ...(title !== undefined ? { title } : {}),
      ...(content !== undefined ? { content } : {}),
    });
    return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};

