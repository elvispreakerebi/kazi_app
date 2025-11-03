import { api } from "../../../_generated/api";

export const regenerateLessonPlanContentHandler = async (ctx: any, request: Request) => {
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

  // Parse lessonPlanId, plus subjectId, weekObj, etc
  let lessonPlanId, subjectId, weekObj, classId, lessonDate;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    lessonPlanId = body.lessonPlanId;
    subjectId = body.subjectId;
    weekObj = body.weekObj;
    classId = body.classId;
    lessonDate = body.lessonDate;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    lessonPlanId = form.get("lessonPlanId") as string | undefined;
    subjectId = form.get("subjectId") as string | undefined;
    weekObj = form.get("weekObj") ? JSON.parse(form.get("weekObj") as string) : undefined;
    classId = form.get("classId") as string | undefined;
    lessonDate = form.get("lessonDate") as string | undefined;
  }
  if (!lessonPlanId) {
    return new Response(JSON.stringify({ error: "Missing lessonPlanId." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const result = await ctx.runAction(api.functions.lessonPlans.regenerateLessonPlanContent, {
    lessonPlanId,
    teacherId,
    subjectId,
    weekObj,
    classId,
    lessonDate: lessonDate ? Number(lessonDate) : undefined,
  });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
