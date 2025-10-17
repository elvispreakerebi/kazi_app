import { api } from "../../../_generated/api";

export const sendPasswordResetHandler = async (ctx: any, req: Request) => {
  try {
    const { email } = await req.json();
    await ctx.runAction(api.functions.auth.sendPasswordResetCodeAction.sendPasswordResetCodeAction, { email });
    return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' }});
  } catch {
    return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' }});
  }
};
