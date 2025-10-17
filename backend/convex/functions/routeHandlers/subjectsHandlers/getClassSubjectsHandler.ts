import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const getClassSubjectsHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const url = new URL(req.url);
  const classId = url.searchParams.get('classId');
  if (!classId) {
    return new Response(JSON.stringify({ error: "Missing classId param." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  try {
    const subjects = await ctx.runQuery(api.functions.subjects.getClassSubjects.getClassSubjects, {
      teacherId: verify.teacherId as Id<"teachers">,
      classId: classId as Id<"classes">,
    });
    return new Response(JSON.stringify(subjects), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};
