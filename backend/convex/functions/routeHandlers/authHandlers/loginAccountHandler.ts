import { api } from "../../../_generated/api";

export const loginAccountHandler = async (ctx: any, req: Request) => {
  try {
    const body = await req.json();
    const { email, password } = body;
    if (!email || !password) {
      return new Response(
        JSON.stringify({ error: "Email and password are required." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    const result = await ctx.runAction(api.functions.auth.loginAccountAction.loginAccountAction, { email, password });
    if (!result || !result.token) {
      // Query for no account for better error message
      const user = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email });
      if (!user) {
        return new Response(
          JSON.stringify({ error: "No account found for this email." }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }
      if (result.error === 'Please enter a valid email and password.') {
        return new Response(
          JSON.stringify({ error: "Invalid email or password format." }),
          { status: 422, headers: { "Content-Type": "application/json" } }
        );
      } else if (result.error && result.error.toLowerCase().includes('google')) {
        return new Response(
          JSON.stringify({ error: "This account uses Google sign in only." }),
          { status: 422, headers: { "Content-Type": "application/json" } }
        );
      } else if (result.error) {
        return new Response(
          JSON.stringify({ error: result.error }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }
      return new Response(
        JSON.stringify({ error: "Invalid credentials." }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      );
    }
    return new Response(
      JSON.stringify(result),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
}
