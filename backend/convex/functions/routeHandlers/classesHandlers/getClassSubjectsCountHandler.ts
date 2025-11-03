import { api } from "../../../_generated/api";

export const getClassSubjectsCountHandler = async (ctx: any, request: Request) => {
  // Auth
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

  let classId: string | undefined;
  const url = new URL(request.url);
  classId = url.searchParams.get("classId") || undefined;
  if (!classId) {
    // fallback to JSON body
    if ((request.headers.get("content-type") || "").includes("application/json")) {
      const body = await request.json();
      classId = body.classId as string;
    }
  }
  if (!classId) {
    return new Response(JSON.stringify({ error: "Missing classId." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const result = await ctx.runQuery(api.functions.classes.getClassSubjectsCount, { classId, teacherId });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
