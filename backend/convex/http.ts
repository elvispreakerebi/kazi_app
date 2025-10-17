import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";
import { Id } from "./_generated/dataModel";

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
          JSON.stringify({ error: "Email and password are required." }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }
      // Call login logic via an action to allow bcrypt and JWT
      const result = await ctx.runAction(api.functions.auth.loginAccountAction.loginAccountAction, { email, password });
      if (!result || !result.token) {
        // Run a direct query to check for 'no user' error for best error copy
        const user = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email });
        if (!user) {
          return new Response(
            JSON.stringify({ error: "No account found for this email." }),
            { status: 401, headers: { "Content-Type": "application/json" } }
          );
        }
        // Custom handling for error copy returned from action
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

http.route({
  path: '/api/auth/resend-verification',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
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
  }),
});

http.route({
  path: '/api/auth/verify-email-code',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
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
  }),
});

http.route({
  path: '/api/auth/send-password-reset',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
    try {
      const { email } = await req.json();
      // Always respond ok=true for privacy
      await ctx.runAction(api.functions.auth.sendPasswordResetCodeAction.sendPasswordResetCodeAction, { email });
      return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' }});
    } catch {
      return new Response(JSON.stringify({ ok: true }), { status: 200, headers: { 'Content-Type': 'application/json' }});
    }
  }),
});

http.route({
  path: '/api/auth/verify-password-reset-code',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
    try {
      const { email, code } = await req.json();
      const result = await ctx.runMutation(api.functions.auth.verifyPasswordResetCode.verifyPasswordResetCode, { email, code });
      return new Response(JSON.stringify(result), { status: 200, headers: { 'Content-Type': 'application/json' }});
    } catch {
      return new Response(JSON.stringify({ ok: false, error: 'Internal error.' }), { status: 500, headers: { 'Content-Type': 'application/json' }});
    }
  }),
});

http.route({
  path: '/api/auth/reset-password',
  method: 'POST',
  handler: httpAction(async (ctx, req) => {
    try {
      const { email, code, newPassword } = await req.json();
      const result = await ctx.runAction(api.functions.auth.resetPasswordAction.resetPasswordAction, { email, code, newPassword });
      return new Response(JSON.stringify(result), { status: 200, headers: { 'Content-Type': 'application/json' }});
    } catch {
      return new Response(JSON.stringify({ ok: false, error: 'Internal error.' }), { status: 500, headers: { 'Content-Type': 'application/json' }});
    }
  }),
});

http.route({
  path: "/api/classes/add",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    // Extract authorization header (Bearer token)
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    // Call Node platform action to verify the token
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let classes;
    try {
      const body = await req.json();
      ({ classes } = body);
    } catch {
      return new Response(
        JSON.stringify({ error: "Invalid JSON body." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    if (!Array.isArray(classes) || classes.length === 0) {
      return new Response(
        JSON.stringify({ error: "A non-empty 'classes' array is required." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    try {
      const result = await ctx.runMutation(api.functions.classes.addClass.addClass, {
        teacherId: verify.teacherId as Id<"teachers">,
        classes
      });
      return new Response(JSON.stringify(result), { status: 201, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(
        JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
        { status: 422, headers: { "Content-Type": "application/json" } }
      );
    }
  })
});

export default http;
