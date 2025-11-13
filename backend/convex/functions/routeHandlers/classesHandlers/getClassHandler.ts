import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const getClassHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
  if (!verify.valid || !verify.teacherId) {
    return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  let classId;
  try {
    const url = new URL(req.url);
    classId = url.searchParams.get("classId");
    if (!classId && (req.headers.get("content-type") || "").includes("application/json")) {
      const body = await req.json();
      classId = body.classId;
    }
  } catch {
    return new Response(JSON.stringify({ error: "Invalid class id or request." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  if (!classId) {
    return new Response(JSON.stringify({ error: "Missing classId." }), { status: 400, headers: { "Content-Type": "application/json" } });
  }
  try {
    const result = await ctx.runQuery(api.functions.classes.getClass.getClass, {
      teacherId: verify.teacherId as Id<"teachers">,
      classId
    });
    return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
  }
};
