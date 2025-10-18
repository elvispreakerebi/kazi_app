import { httpRouter } from "convex/server";
import { httpAction } from "./_generated/server";
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
import { addSubjectsHandler } from "./functions/routeHandlers/subjectsHandlers/addSubjectsHandler";
import { deleteSubjectHandler } from "./functions/routeHandlers/subjectsHandlers/deleteSubjectHandler";
import { editSubjectHandler } from "./functions/routeHandlers/subjectsHandlers/editSubjectHandler";
import { getClassSubjectsHandler } from "./functions/routeHandlers/subjectsHandlers/getClassSubjectsHandler";
import { getTeacherDetailsHandler } from "./functions/routeHandlers/teachersHandlers/getTeacherDetailsHandler";
import { generateUploadUrlHandler } from "./functions/routeHandlers/fileHandlers/generateUploadUrlHandler";
import { parseAndExtractTopicsBatchHandler } from "./functions/routeHandlers/schemeOfWorkHandlers/parseAndExtractTopicsBatchHandler";
import { uploadCurriculumHandler } from "./functions/routeHandlers/fileHandlers/uploadCurriculumHandler";
import { parseAndExtractCurriculumHandler } from "./functions/routeHandlers/fileHandlers/parseAndExtractCurriculumHandler";

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
  handler: httpAction(addSubjectsHandler),
});

http.route({
  path: "/api/subjects/delete",
  method: "POST",
  handler: httpAction(deleteSubjectHandler),
});

http.route({
  path: "/api/subjects/edit",
  method: "POST",
  handler: httpAction(editSubjectHandler),
});

http.route({
  path: "/api/subjects/list",
  method: "GET",
  handler: httpAction(getClassSubjectsHandler),
});

// Teachers Routes
http.route({
  path: "/api/teacher/details",
  method: "GET",
  handler: httpAction(getTeacherDetailsHandler),
});

http.route({
  path: "/api/file/generate-upload-url",
  method: "POST",
  handler: httpAction(generateUploadUrlHandler),
});

// File Routes
http.route({
  path: "/api/file/upload-curriculum",
  method: "POST",
  handler: httpAction(uploadCurriculumHandler),
});

http.route({
  path: "/api/file/parse-curriculum",
  method: "POST",
  handler: httpAction(parseAndExtractCurriculumHandler),
});

http.route({
  path: "/api/schemeOfWork/parse-and-extract-batch",
  method: "POST",
  handler: httpAction(parseAndExtractTopicsBatchHandler),
});

export default http;
