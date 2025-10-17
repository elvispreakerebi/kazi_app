import { api } from "../../../_generated/api";

export const googleIdTokenLoginHandler = async (ctx: any, req: Request) => {
  try {
    const { idToken, name } = await req.json();
    if (!idToken) {
      return new Response(JSON.stringify({ message: 'Missing idToken' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }
    const result = await ctx.runAction(api.functions.auth.googleOAuthAction.handleGoogleIdTokenLogin, { idToken, name });
    if (result && result.token) {
      return new Response(JSON.stringify({ token: result.token }), { status: 200, headers: { 'Content-Type': 'application/json' }});
    } else {
      return new Response(JSON.stringify({ error: result?.error || 'Login failed.' }), { status: 401, headers: { 'Content-Type': 'application/json' }});
    }
  } catch (err) {
    return new Response(JSON.stringify({ message: err instanceof Error ? err.message : String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
