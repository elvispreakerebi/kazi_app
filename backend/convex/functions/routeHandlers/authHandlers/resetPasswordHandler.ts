import { api } from "../../../_generated/api";

export const resetPasswordHandler = async (ctx: any, req: Request) => {
  try {
    const { email, code, newPassword } = await req.json();
    const result = await ctx.runAction(api.functions.auth.resetPasswordAction.resetPasswordAction, { email, code, newPassword });
    return new Response(JSON.stringify(result), { status: 200, headers: { 'Content-Type': 'application/json' }});
  } catch (err) {
    return new Response(JSON.stringify({ ok: false, error: 'Internal error.' }), { status: 500, headers: { 'Content-Type': 'application/json' }});
  }
};
