import { api } from "../../../_generated/api";

export const resendVerificationHandler = async (ctx: any, req: Request) => {
  try {
    const body = await req.json();
    const { email, name } = body;
    if (!email) {
      return new Response(
        JSON.stringify({ message: 'Missing email field.' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }
    const result = await ctx.runAction(api.functions.auth.sendVerificationEmailAction.sendVerificationEmailAction, {
      email,
      name
    });
    if (!result.ok) {
      return new Response(
        JSON.stringify({ ok: false, error: result.error }),
        { status: 429, headers: { 'Content-Type': 'application/json' } }
      );
    }
    return new Response(
      JSON.stringify({ ok: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ message: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
}
