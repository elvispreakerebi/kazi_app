import { api } from "../../../_generated/api";

export const parseAndExtractCurriculumHandler = async (ctx: any, request: Request) => {
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

  let curriculumId: string | undefined;
  const contentType = request.headers.get("content-type") || "";
  if (contentType.includes("application/json")) {
    const body = await request.json();
    curriculumId = body.curriculumId as string;
  } else if (contentType.includes("multipart/form-data")) {
    const form = await request.formData();
    curriculumId = form.get("curriculumId") as string;
  }

  if (typeof curriculumId !== "string") {
    return new Response(JSON.stringify({ error: "Missing curriculumId." }), {
      status: 400,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
  // Call extraction action
  try {
    const result = await ctx.runAction(api.functions.curriculum.parseAndExtractCurriculumAction, { curriculumId });
    return new Response(JSON.stringify({ ok: true, ...result }), {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ ok: false, error: err instanceof Error ? err.message : String(err) }), {
      status: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
};
