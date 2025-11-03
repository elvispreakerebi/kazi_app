import { api } from "../../../_generated/api";

export const generateLessonPlanHandler = async (ctx: any, request: Request) => {
  // Authenticate
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }
  const token = authHeader.split(" ")[1];
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction, { token });
  if (!verify.valid) {
    return new Response(JSON.stringify({ error: "Invalid or expired token." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }
  const teacherId = verify.teacherId;

  // Get data
  let data: any = {};
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    data = await request.json();
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    data.subjectId = form.get("subjectId");
    data.weekObj = form.get("weekObj") && typeof form.get("weekObj") === 'string' ? JSON.parse(form.get("weekObj") as string) : form.get("weekObj");
    data.lessonDate = form.get("lessonDate");
    data.classId = form.get("classId");
  }
  // Validate required fields
  if (!data.subjectId || !data.weekObj || !data.lessonDate) {
    return new Response(JSON.stringify({ error: "Missing required field(s): subjectId, weekObj, or lessonDate." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }

  try {
    const result = await ctx.runAction("functions/lessonPlans/generateLessonPlanAction", {
      teacherId,
      subjectId: data.subjectId,
      weekObj: data.weekObj,
      lessonDate: Number(data.lessonDate),
      classId: data.classId || undefined,
    });
    return new Response(JSON.stringify({ ok: true, ...result }), {
      status: 200,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ ok: false, error: err instanceof Error ? err.message : String(err) }), {
      status: 500,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }
};
