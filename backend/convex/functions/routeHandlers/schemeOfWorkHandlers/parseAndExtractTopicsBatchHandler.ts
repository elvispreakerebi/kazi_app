import { api } from '../../../_generated/api';

export const parseAndExtractTopicsBatchHandler = async (ctx: any, req: Request) => {
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
    const body = await req.json();
    if (!Array.isArray(body)) {
      return new Response(JSON.stringify({ error: "Request JSON must be an array of {schemeOfWorkId, currentWeek}" }), {
        status: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json",
          Vary: "origin"
        }
      });
    }
    const results = [];
    for (const item of body) {
      if (!item || typeof item.schemeOfWorkId !== 'string') {
        results.push({ ...item, ok: false, error: 'Invalid schemeOfWorkId or structure.' });
        continue;
      }
      try {
        const result = await ctx.runAction(api.functions.schemeOfWork.parseAndExtractTopicsAction, {
          schemeOfWorkId: item.schemeOfWorkId,
          currentWeek: item.currentWeek
        });
        results.push({ ...item, ...result, ok: true });
      } catch (err: any) {
        results.push({ ...item, ok: false, error: err?.message || String(err) });
      }
    }
    return new Response(JSON.stringify(results), {
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
