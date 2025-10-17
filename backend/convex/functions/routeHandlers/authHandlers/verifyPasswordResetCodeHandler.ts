import { api } from "../../../_generated/api";

export const verifyPasswordResetCodeHandler = async (ctx: any, req: Request) => {
  try {
    const { email, code } = await req.json();
    const result = await ctx.runMutation(api.functions.auth.verifyPasswordResetCode.verifyPasswordResetCode, { email, code });
    return new Response(JSON.stringify(result), { status: 200, headers: { 'Content-Type': 'application/json' }});
  } catch (err) {
    return new Response(JSON.stringify({ ok: false, error: 'Internal error.' }), { status: 500, headers: { 'Content-Type': 'application/json' }});
  }
};
