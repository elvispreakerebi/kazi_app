import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
import { api } from "./_generated/api";
import { Id } from "./_generated/dataModel";
import { createAccountHandler } from "./functions/routeHandlers/authHandlers/createAccountHandler";
import { loginAccountHandler } from "./functions/routeHandlers/authHandlers/loginAccountHandler";
import { googleIdTokenLoginHandler } from "./functions/routeHandlers/authHandlers/googleIdTokenLoginHandler";
import { resendVerificationHandler } from "./functions/routeHandlers/authHandlers/resendVerificationHandler";
import { verifyEmailCodeHandler } from "./functions/routeHandlers/authHandlers/verifyEmailCodeHandler";
import { sendPasswordResetHandler } from "./functions/routeHandlers/authHandlers/sendPasswordResetHandler";
import { verifyPasswordResetCodeHandler } from "./functions/routeHandlers/authHandlers/verifyPasswordResetCodeHandler";
import { resetPasswordHandler } from "./functions/routeHandlers/authHandlers/resetPasswordHandler";

const http = httpRouter();

http.route({
  path: "/api/auth/create-account",
  method: "POST",
  handler: httpAction(createAccountHandler),
});

http.route({
  path: "/api/auth/login-account",
  method: "POST",
  handler: httpAction(loginAccountHandler),
});

http.route({
  path: '/api/auth/google-idtoken-login',
  method: 'POST',
  handler: httpAction(googleIdTokenLoginHandler),
});

http.route({
  path: '/api/auth/resend-verification',
  method: 'POST',
  handler: httpAction(resendVerificationHandler),
});

http.route({
  path: '/api/auth/verify-email-code',
  method: 'POST',
  handler: httpAction(verifyEmailCodeHandler),
});

http.route({
  path: '/api/auth/send-password-reset',
  method: 'POST',
  handler: httpAction(sendPasswordResetHandler),
});

http.route({
  path: '/api/auth/verify-password-reset-code',
  method: 'POST',
  handler: httpAction(verifyPasswordResetCodeHandler),
});

http.route({
  path: '/api/auth/reset-password',
  method: 'POST',
  handler: httpAction(resetPasswordHandler),
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

http.route({
  path: "/api/classes/delete",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let classId;
    try {
      const body = await req.json();
      ({ classId } = body);
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    if (!classId) {
      return new Response(JSON.stringify({ error: "classId is required." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    try {
      const result = await ctx.runMutation(api.functions.classes.deleteClass.deleteClass, { teacherId: verify.teacherId as Id<"teachers">, classId });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

http.route({
  path: "/api/classes/edit",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let classId, name, gradeLevel, academicYear;
    try {
      const body = await req.json();
      ({ classId, name, gradeLevel, academicYear } = body);
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    if (!classId) {
      return new Response(JSON.stringify({ error: "classId is required." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    try {
      const result = await ctx.runMutation(api.functions.classes.editClass.editClass, {
        teacherId: verify.teacherId as Id<"teachers">,
        classId,
        ...(name !== undefined ? { name } : {}),
        ...(gradeLevel !== undefined ? { gradeLevel } : {}),
        ...(academicYear !== undefined ? { academicYear } : {}),
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

http.route({
  path: "/api/classes/list",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    try {
      const classes = await ctx.runQuery(api.functions.classes.getTeacherClasses.getTeacherClasses, {
        teacherId: verify.teacherId as Id<"teachers">,
      });
      return new Response(JSON.stringify(classes), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

http.route({
  path: "/api/subjects/add",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let classId, subjects;
    try {
      const body = await req.json();
      ({ classId, subjects } = body);
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    if (!classId || !Array.isArray(subjects) || subjects.length === 0) {
      return new Response(
        JSON.stringify({ error: "classId and a non-empty 'subjects' array are required." }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }
    try {
      const result = await ctx.runMutation(api.functions.subjects.addSubjects.addSubjects, {
        teacherId: verify.teacherId as Id<"teachers">,
        classId,
        subjects
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

http.route({
  path: "/api/subjects/delete",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let subjectId;
    try {
      const body = await req.json();
      ({ subjectId } = body);
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    if (!subjectId) {
      return new Response(JSON.stringify({ error: "subjectId is required." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    try {
      const result = await ctx.runMutation(api.functions.subjects.deleteSubject.deleteSubject, {
        teacherId: verify.teacherId as Id<"teachers">,
        subjectId
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

http.route({
  path: "/api/subjects/edit",
  method: "POST",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    let subjectId, name;
    try {
      const body = await req.json();
      ({ subjectId, name } = body);
    } catch {
      return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    if (!subjectId || !name) {
      return new Response(JSON.stringify({ error: "subjectId and name are required." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    try {
      const result = await ctx.runMutation(api.functions.subjects.editSubject.editSubject, {
        teacherId: verify.teacherId as Id<"teachers">,
        subjectId,
        name
      });
      return new Response(JSON.stringify(result), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

http.route({
  path: "/api/subjects/list",
  method: "GET",
  handler: httpAction(async (ctx, req) => {
    const auth = req.headers.get('authorization') || req.headers.get('Authorization');
    if (!auth || !auth.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    const url = new URL(req.url);
    const classId = url.searchParams.get('classId');
    if (!classId) {
      return new Response(JSON.stringify({ error: "Missing classId param." }), { status: 400, headers: { "Content-Type": "application/json" } });
    }
    const token = auth.slice(7);
    const verify = await ctx.runAction(api.functions.auth.verifyTokenAction.verifyTokenAction, { token });
    if (!verify.valid || !verify.teacherId) {
      return new Response(JSON.stringify({ error: verify.error || "Unauthorized." }), { status: 401, headers: { "Content-Type": "application/json" } });
    }
    try {
      const subjects = await ctx.runQuery(api.functions.subjects.getClassSubjects.getClassSubjects, {
        teacherId: verify.teacherId as Id<"teachers">,
        classId: classId as Id<"classes">,
      });
      return new Response(JSON.stringify(subjects), { status: 200, headers: { "Content-Type": "application/json" } });
    } catch (err) {
      return new Response(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }), { status: 422, headers: { "Content-Type": "application/json" } });
    }
  })
});

export default http;
