import { api } from "../../../_generated/api";

export const editLessonPlanContentHandler = async (ctx: any, request: Request) => {
  // Auth
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" }
    });
  }
  const token = authHeader.split(" ")[1];
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction, { token });
  if (!verify.valid) {
    return new Response(JSON.stringify({ error: "Invalid or expired token." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" }
    });
  }
  const teacherId = verify.teacherId;

  // Parse lessonPlanId and content
  let lessonPlanId: string | undefined;
  let content: string | undefined;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    lessonPlanId = body.lessonPlanId;
    content = body.content;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    lessonPlanId = form.get("lessonPlanId") as string | undefined;
    content = form.get("content") as string | undefined;
  }
  if (!lessonPlanId || !content) {
    return new Response(JSON.stringify({ error: "Missing lessonPlanId or content." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" }
    });
  }
  const result = await ctx.runMutation(api.functions.lessonPlans.editLessonPlanContent, {
    lessonPlanId,
    teacherId,
    content,
  });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
