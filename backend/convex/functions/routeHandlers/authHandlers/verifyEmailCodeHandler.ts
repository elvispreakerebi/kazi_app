import { api } from "../../../_generated/api";

export const verifyEmailCodeHandler = async (ctx: any, req: Request) => {
  try {
    const body = await req.json();
    const { email, code } = body;
    if (!email || !code) {
      return new Response(JSON.stringify({ ok: false, error: 'Missing email or code.' }), { status: 400, headers: { 'Content-Type': 'application/json' } });
    }
    const result = await ctx.runMutation(api.functions.auth.verifyEmailCode.verifyEmailCode, { email, code });
    if (result.ok) {
      return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' } });
    } else {
      return new Response(JSON.stringify({ ok: false, error: result.error }), { status: 422, headers: { 'Content-Type': 'application/json' } });
    }
  } catch (err) {
    return new Response(JSON.stringify({ ok: false, error: String(err) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
}
