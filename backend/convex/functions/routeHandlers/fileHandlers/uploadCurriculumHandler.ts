import { api } from "../../../_generated/api";

export const uploadCurriculumHandler = async (ctx: any, request: Request) => {
  // 1. Enforce token-based security
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header." }), {
      status: 401,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
  const token = authHeader.split(" ")[1];
  const verify = await ctx.runAction(api.functions.auth.verifyTokenAction, { token });
  if (!verify.valid) {
    return new Response(JSON.stringify({ error: "Invalid or expired token." }), {
      status: 401,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }

  // 2. Get form data
  const form = await request.formData();
  const file = form.get("file");
  const teacherId = form.get("teacherId");
  if (!file || typeof teacherId !== "string") {
    return new Response(JSON.stringify({ error: "Missing fields: file or teacherId." }), {
      status: 400,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
  const { fileId } = await ctx.storage.store(file, { returnFileId: true });
  const result = await ctx.runMutation(api.functions.curriculum.addCurriculum, {
    teacherId,
    fileId,
  });
  return new Response(JSON.stringify({ curriculumId: result.id, ...result }), {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      Vary: "origin"
    }
  });
};
