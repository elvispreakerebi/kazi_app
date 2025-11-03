import { api } from "../../../_generated/api";

export const getTeacherOverviewCountsHandler = async (ctx: any, request: Request) => {
  // Auth: require Bearer token
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const token = authHeader.split(" ")[1];
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction, { token });
  if (!verify.valid) {
    return new Response(JSON.stringify({ error: "Invalid or expired token." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const teacherId = verify.teacherId;

  // Query for counts
  const result = await ctx.runQuery(api.functions.teachers.getTeacherOverviewCounts, { teacherId });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
