import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";

const http = httpRouter();


http.route({
  path: "/api/auth/crate-account",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    try {
      const body = await req.json();
      const { email, password, name } = body;
      if (!email || !password || !name) {
        return new Response(
          JSON.stringify({ message: "Missing required fields." }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }
      // Use createAccountAction for registration
      const result = await ctx.runAction(api.functions.auth.createAccountAction.createAccountAction, { email, password, name });
      return new Response(
        JSON.stringify({ result }),
        { status: 201, headers: { "Content-Type": "application/json" } }
      );
    } catch (err) {
      return new Response(
        JSON.stringify({ message: err instanceof Error ? err.message : String(err) }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

http.route({
  path: "/api/auth/login-account",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    try {
      const body = await req.json();
      const { email, password } = body;
      if (!email || !password) {
        return new Response(
          JSON.stringify({ message: "Missing required fields." }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }
      // Call login logic via an action to allow bcrypt and JWT
      const result = await ctx.runAction(api.functions.auth.loginAccountAction.loginAccountAction, { email, password });
      if (!result || !result.token) {
        return new Response(
          JSON.stringify({ message: "Invalid credentials." }),
          { status: 401, headers: { "Content-Type": "application/json" } }
        );
      }
      return new Response(
        JSON.stringify(result),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    } catch (err) {
      return new Response(
        JSON.stringify({ message: err instanceof Error ? err.message : String(err) }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  }),
});

http.route({
  path: '/api/auth/google-idtoken-login',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
    try {
      const { idToken, name } = await req.json();
      if (!idToken) {
        return new Response(JSON.stringify({ message: 'Missing idToken' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }
      // Call action to handle Google ID token (should verify, find/create teacher, return signed JWT)
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
  })
});

export default http;
