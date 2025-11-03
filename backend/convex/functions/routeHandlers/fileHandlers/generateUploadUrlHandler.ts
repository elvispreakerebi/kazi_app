import { api } from "../../../_generated/api";

export const generateUploadUrlHandler = async (ctx: any, request: Request) => {
  // Enforce token-based security
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
  const form = await request.formData();
  const file = form.get("file");
  const teacherId = form.get("teacherId");
  const subjectId = form.get("subjectId");
  if (!file || typeof teacherId !== "string" || typeof subjectId !== "string") {
    return new Response(JSON.stringify({ error: "Missing fields: file, teacherId, or subjectId." }), {
      status: 400,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
  const storageId = await ctx.storage.store(file);
  const { id } = await ctx.runMutation(api.functions.schemeOfWork.addSchemeOfWork, {
    teacherId,
    subjectId,
    storageId,
  });
  return new Response(JSON.stringify({ schemeOfWorkId: id }), {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      Vary: "origin"
    }
  });
};
