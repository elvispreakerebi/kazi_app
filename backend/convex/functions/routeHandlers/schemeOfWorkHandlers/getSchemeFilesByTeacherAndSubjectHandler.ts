import { getSchemeFilesByTeacherAndSubject } from "../../schemeOfWork/getSchemeFilesByTeacherAndSubject";
import { api } from "../../../_generated/api";

export const getSchemeFilesByTeacherAndSubjectHandler = async (ctx: any, request: Request) => {
  // Auth
  const authHeader = request.headers.get("authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(JSON.stringify({ error: "Missing or invalid Authorization header." }), {
      status: 401,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json", Vary: "origin" },
    });
  }
  const token = authHeader.split(" ")[1];
  await ctx.runAction(api.functions.auth.verifyTokenAction, { token });
  // You can add additional checks with verify here.
  // Parse body
  const { teacherId, subjectId } = await request.json();
  const files = await ctx.runQuery(getSchemeFilesByTeacherAndSubject, {
    teacherId, subjectId
  });
  return new Response(JSON.stringify(files), { status: 200 });
};
