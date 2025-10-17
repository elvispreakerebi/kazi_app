import { api } from "../../../_generated/api";

export const generateUploadUrlHandler = async (ctx: any, request: Request) => {
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
