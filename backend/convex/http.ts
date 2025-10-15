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

export default http;
