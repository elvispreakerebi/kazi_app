import { api } from '../../../_generated/api';

export const parseAndExtractTopicsHandler = async (ctx: any, req: Request) => {
  try {
    const authHeader = req.headers.get("authorization");
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
    const { schemeOfWorkId, currentWeek } = await req.json();
    if (!schemeOfWorkId || (currentWeek !== undefined && typeof currentWeek !== 'number')) {
      return new Response(JSON.stringify({ error: "Missing or invalid 'schemeOfWorkId' or 'currentWeek' param."}), {
        status: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
          Vary: "origin"
        }
      });
    }
    const result = await ctx.runAction(api.functions.schemeOfWork.parseAndExtractTopicsAction, {
      schemeOfWorkId,
      currentWeek
    });
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err?.message || String(err) }), {
      status: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
        Vary: "origin"
      }
    });
  }
};
