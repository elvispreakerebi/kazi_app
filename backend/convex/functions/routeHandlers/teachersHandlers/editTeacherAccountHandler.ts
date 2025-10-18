import { api } from "../../../_generated/api";

export const editTeacherAccountHandler = async (ctx: any, request: Request) => {
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

  // Parse name/email/password
  let name, email, password;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    name = typeof body.name === "string" ? body.name : undefined;
    email = typeof body.email === "string" ? body.email : undefined;
    password = typeof body.password === "string" ? body.password : undefined;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    name = form.get("name") as string | undefined;
    email = form.get("email") as string | undefined;
    password = form.get("password") as string | undefined;
  }
  if (!name && !email && !password) {
    return new Response(JSON.stringify({ error: "Missing name, email, or password." }), {
      status: 400,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
    });
  }
  const result = await ctx.runMutation(api.functions.teachers.editTeacherAccount, {
    teacherId,
    name,
    email,
    password,
  });
  return new Response(JSON.stringify(result), {
    status: 200,
    headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" },
  });
};
