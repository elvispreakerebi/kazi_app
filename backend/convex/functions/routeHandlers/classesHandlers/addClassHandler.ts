import { api } from "../../../_generated/api";
import { Id } from "../../../_generated/dataModel";

export const addClassHandler = async (ctx: any, req: Request) => {
  const auth = req.headers.get('authorization') || req.headers.get('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
  }
  const token = auth.slice(7);
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
};
