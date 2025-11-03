import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const getTeacherDetailsHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  try {
    const teacher = await ctx.runQuery(api.functions.teachers.getTeacherDetails.getTeacherDetails, {
      teacherId: verify.teacherId as Id<"teachers">,
    });
    if (!teacher) {
      return new Response(JSON.stringify({ error: "Teacher not found." }), { status: 404, headers: { "Content-Type": "application/json" } });
    }
    return new Response(JSON.stringify(teacher), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};
