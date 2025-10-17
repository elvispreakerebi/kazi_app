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
import { addClassHandler } from "./functions/routeHandlers/classesHandlers/addClassHandler";
import { deleteClassHandler } from "./functions/routeHandlers/classesHandlers/deleteClassHandler";
import { editClassHandler } from "./functions/routeHandlers/classesHandlers/editClassHandler";
import { getTeacherClassesHandler } from "./functions/routeHandlers/classesHandlers/getTeacherClassesHandler";

const http = httpRouter();

// Auth Routes
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

// Classes Routes
http.route({
  path: "/api/classes/add",
  method: "POST",
  handler: httpAction(addClassHandler),
});

http.route({
  path: "/api/classes/delete",
  method: "POST",
  handler: httpAction(deleteClassHandler),
});

http.route({
  path: "/api/classes/edit",
  method: "POST",
  handler: httpAction(editClassHandler),
});

http.route({
  path: "/api/classes/list",
  method: "GET",
  handler: httpAction(getTeacherClassesHandler),
});

// Subjects Routes
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
