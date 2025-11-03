import { api } from "../../../_generated/api";

export const deleteLessonPlanHandler = async (ctx: any, request: Request) => {
  // Require JWT
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

  // Parse lessonPlanId
  let lessonPlanId: string | undefined;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    lessonPlanId = body.lessonPlanId;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    lessonPlanId = form.get("lessonPlanId") as string | undefined;
  }
  if (!lessonPlanId) {
    return new Response(JSON.stringify({ error: "Missing lessonPlanId." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const result = await ctx.runMutation(api.functions.lessonPlans.deleteLessonPlan, {
    lessonPlanId,
    teacherId,
  });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
