import { api } from "../../_generated/api";

export const createAccountHandler = async (ctx: any, req: Request) => {
  try {
    const body = await req.json();
    const { email, password, name } = body;
    if (!email || !password || !name) {
      return new Response(
        JSON.stringify({ error: "All fields are required." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    // Use createAccountAction for registration
    const result = await ctx.runAction(api.functions.auth.createAccountAction.createAccountAction, { email, password, name });
    if (result?.error) {
      // Validation error (password or email) or duplicate account
      // catch common case: duplicate email vs. validation error
      if (result.error.toLowerCase().includes('already exists')) {
        return new Response(
          JSON.stringify({ error: "An account with this email already exists." }),
          { status: 409, headers: { "Content-Type": "application/json" } }
        );
      } else if (result.error.toLowerCase().includes('invalid email')) {
        return new Response(
          JSON.stringify({ error: "Invalid email address." }),
          { status: 422, headers: { "Content-Type": "application/json" } }
        );
      } else if (result.error.toLowerCase().includes('password')) {
        return new Response(
          JSON.stringify({ error: result.error }),
          { status: 422, headers: { "Content-Type": "application/json" } }
        );
      }
      // Fallback: forward any other error
      return new Response(
        JSON.stringify({ error: result.error }),
        { status: 422, headers: { "Content-Type": "application/json" } }
      );
    }
    // Trigger verification email after success, only for email/pw
    await ctx.runAction(api.functions.auth.sendVerificationEmailAction.sendVerificationEmailAction, {
      email,
      name
    });
    return new Response(
      JSON.stringify({ result, verificationEmailSent: true }),
      { status: 201, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
}
