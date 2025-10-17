import { api } from '../../../_generated/api';

export const parseAndExtractTopicsHandler = async (ctx: any, req: Request) => {
  try {
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
