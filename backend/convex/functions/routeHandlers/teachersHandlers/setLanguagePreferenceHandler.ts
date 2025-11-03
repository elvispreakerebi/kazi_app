import { api } from "../../../_generated/api";

export const setLanguagePreferenceHandler = async (ctx: any, request: Request) => {
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

  let language;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    language = typeof body.language === "string" ? body.language : undefined;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    language = form.get("language") as string | undefined;
  }
  if (!language) {
    return new Response(JSON.stringify({ error: "Missing language." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const result = await ctx.runMutation(api.functions.teachers.setLanguagePreference, {
    teacherId,
    language,
  });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
