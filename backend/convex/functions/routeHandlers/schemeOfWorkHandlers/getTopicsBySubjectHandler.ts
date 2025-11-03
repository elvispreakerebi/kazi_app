import { api } from "../../../_generated/api";

export const getTopicsBySubjectHandler = async (ctx: any, request: Request) => {
  // Auth
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

  let subjectId: string | undefined;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    subjectId = body.subjectId as string;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    subjectId = form.get("subjectId") as string;
  } else {
    const url = new URL(request.url);
    subjectId = url.searchParams.get("subjectId") || undefined;
  }

  if (!subjectId) {
    return new Response(JSON.stringify({ error: "Missing subjectId." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }

  // Query topics for this subject and teacher
  try {
    const topics = await ctx.runQuery(api.functions.schemeOfWork.getTopicsBySubject, { subjectId, teacherId });
    return new Response(JSON.stringify({ topics }), {
      status: 200,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), {
      status: 500,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }
};
