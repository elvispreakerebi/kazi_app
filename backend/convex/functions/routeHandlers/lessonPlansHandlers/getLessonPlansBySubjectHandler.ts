import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const getLessonPlansBySubjectHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  
  let subjectId;
  try {
    const url = new URL(req.url);
    subjectId = url.searchParams.get("subjectId");
    if (!subjectId && (req.headers.get("content-type") || "").includes("application/json")) {
      const body = await req.json();
      subjectId = body.subjectId;
    }
  } catch {
    return new Response(JSON.stringify({ error: "Invalid subject id or request." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  
  if (!subjectId) {
    return new Response(JSON.stringify({ error: "Missing subjectId." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  
  try {
    const result = await ctx.runQuery(api.functions.lessonPlans.getLessonPlansBySubject.getLessonPlansBySubject, {
      teacherId: verify.teacherId as Id<"teachers">,
      subjectId: subjectId as Id<"subjects">,
    });
    return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};

