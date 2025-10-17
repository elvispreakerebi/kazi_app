/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as functions_auth__patchTeacherVerification from "../functions/auth/_patchTeacherVerification.js";
import type * as functions_auth__resetTeacherPassword from "../functions/auth/_resetTeacherPassword.js";
import type * as functions_auth_createAccount from "../functions/auth/createAccount.js";
import type * as functions_auth_createAccountAction from "../functions/auth/createAccountAction.js";
import type * as functions_auth_findTeacherByEmail from "../functions/auth/findTeacherByEmail.js";
import type * as functions_auth_googleAuth from "../functions/auth/googleAuth.js";
import type * as functions_auth_googleOAuthAction from "../functions/auth/googleOAuthAction.js";
import type * as functions_auth_loginAccountAction from "../functions/auth/loginAccountAction.js";
import type * as functions_auth_resetPasswordAction from "../functions/auth/resetPasswordAction.js";
import type * as functions_auth_sendPasswordResetCodeAction from "../functions/auth/sendPasswordResetCodeAction.js";
import type * as functions_auth_sendVerificationEmailAction from "../functions/auth/sendVerificationEmailAction.js";
import type * as functions_auth_verifyEmailCode from "../functions/auth/verifyEmailCode.js";
import type * as functions_auth_verifyPasswordResetCode from "../functions/auth/verifyPasswordResetCode.js";
import type * as functions_auth_verifyTokenAction from "../functions/auth/verifyTokenAction.js";
import type * as functions_classes_addClass from "../functions/classes/addClass.js";
import type * as functions_classes_deleteClass from "../functions/classes/deleteClass.js";
import type * as functions_classes_editClass from "../functions/classes/editClass.js";
import type * as functions_classes_getTeacherClasses from "../functions/classes/getTeacherClasses.js";
import type * as functions_routeHandlers_authHandlers_createAccountHandler from "../functions/routeHandlers/authHandlers/createAccountHandler.js";
import type * as functions_routeHandlers_authHandlers_googleIdTokenLoginHandler from "../functions/routeHandlers/authHandlers/googleIdTokenLoginHandler.js";
import type * as functions_routeHandlers_authHandlers_loginAccountHandler from "../functions/routeHandlers/authHandlers/loginAccountHandler.js";
import type * as functions_routeHandlers_authHandlers_resendVerificationHandler from "../functions/routeHandlers/authHandlers/resendVerificationHandler.js";
import type * as functions_routeHandlers_authHandlers_resetPasswordHandler from "../functions/routeHandlers/authHandlers/resetPasswordHandler.js";
import type * as functions_routeHandlers_authHandlers_sendPasswordResetHandler from "../functions/routeHandlers/authHandlers/sendPasswordResetHandler.js";
import type * as functions_routeHandlers_authHandlers_verifyEmailCodeHandler from "../functions/routeHandlers/authHandlers/verifyEmailCodeHandler.js";
import type * as functions_routeHandlers_authHandlers_verifyPasswordResetCodeHandler from "../functions/routeHandlers/authHandlers/verifyPasswordResetCodeHandler.js";
import type * as functions_routeHandlers_classesHandlers_addClassHandler from "../functions/routeHandlers/classesHandlers/addClassHandler.js";
import type * as functions_routeHandlers_classesHandlers_deleteClassHandler from "../functions/routeHandlers/classesHandlers/deleteClassHandler.js";
import type * as functions_routeHandlers_classesHandlers_editClassHandler from "../functions/routeHandlers/classesHandlers/editClassHandler.js";
import type * as functions_routeHandlers_classesHandlers_getTeacherClassesHandler from "../functions/routeHandlers/classesHandlers/getTeacherClassesHandler.js";
import type * as functions_routeHandlers_fileHandlers_generateUploadUrlHandler from "../functions/routeHandlers/fileHandlers/generateUploadUrlHandler.js";
import type * as functions_routeHandlers_subjectsHandlers_addSubjectsHandler from "../functions/routeHandlers/subjectsHandlers/addSubjectsHandler.js";
import type * as functions_routeHandlers_subjectsHandlers_deleteSubjectHandler from "../functions/routeHandlers/subjectsHandlers/deleteSubjectHandler.js";
import type * as functions_routeHandlers_subjectsHandlers_editSubjectHandler from "../functions/routeHandlers/subjectsHandlers/editSubjectHandler.js";
import type * as functions_routeHandlers_subjectsHandlers_getClassSubjectsHandler from "../functions/routeHandlers/subjectsHandlers/getClassSubjectsHandler.js";
import type * as functions_routeHandlers_teachersHandlers_getTeacherDetailsHandler from "../functions/routeHandlers/teachersHandlers/getTeacherDetailsHandler.js";
import type * as functions_schemeOfWork_addSchemeOfWork from "../functions/schemeOfWork/addSchemeOfWork.js";
import type * as functions_schemeOfWork_parseAndExtractTopicsAction from "../functions/schemeOfWork/parseAndExtractTopicsAction.js";
import type * as functions_subjects_addSubjects from "../functions/subjects/addSubjects.js";
import type * as functions_subjects_deleteSubject from "../functions/subjects/deleteSubject.js";
import type * as functions_subjects_editSubject from "../functions/subjects/editSubject.js";
import type * as functions_subjects_getClassSubjects from "../functions/subjects/getClassSubjects.js";
import type * as functions_teachers_getTeacherDetails from "../functions/teachers/getTeacherDetails.js";
import type * as http from "../http.js";
import type * as myFunctions from "../myFunctions.js";
import type * as utils_code from "../utils/code.js";
import type * as utils_resend from "../utils/resend.js";
import type * as utils_text from "../utils/text.js";
import type * as utils_validation from "../utils/validation.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

/**
 * A utility for referencing Convex functions in your app's API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
declare const fullApi: ApiFromModules<{
  "functions/auth/_patchTeacherVerification": typeof functions_auth__patchTeacherVerification;
  "functions/auth/_resetTeacherPassword": typeof functions_auth__resetTeacherPassword;
  "functions/auth/createAccount": typeof functions_auth_createAccount;
  "functions/auth/createAccountAction": typeof functions_auth_createAccountAction;
  "functions/auth/findTeacherByEmail": typeof functions_auth_findTeacherByEmail;
  "functions/auth/googleAuth": typeof functions_auth_googleAuth;
  "functions/auth/googleOAuthAction": typeof functions_auth_googleOAuthAction;
  "functions/auth/loginAccountAction": typeof functions_auth_loginAccountAction;
  "functions/auth/resetPasswordAction": typeof functions_auth_resetPasswordAction;
  "functions/auth/sendPasswordResetCodeAction": typeof functions_auth_sendPasswordResetCodeAction;
  "functions/auth/sendVerificationEmailAction": typeof functions_auth_sendVerificationEmailAction;
  "functions/auth/verifyEmailCode": typeof functions_auth_verifyEmailCode;
  "functions/auth/verifyPasswordResetCode": typeof functions_auth_verifyPasswordResetCode;
  "functions/auth/verifyTokenAction": typeof functions_auth_verifyTokenAction;
  "functions/classes/addClass": typeof functions_classes_addClass;
  "functions/classes/deleteClass": typeof functions_classes_deleteClass;
  "functions/classes/editClass": typeof functions_classes_editClass;
  "functions/classes/getTeacherClasses": typeof functions_classes_getTeacherClasses;
  "functions/routeHandlers/authHandlers/createAccountHandler": typeof functions_routeHandlers_authHandlers_createAccountHandler;
  "functions/routeHandlers/authHandlers/googleIdTokenLoginHandler": typeof functions_routeHandlers_authHandlers_googleIdTokenLoginHandler;
  "functions/routeHandlers/authHandlers/loginAccountHandler": typeof functions_routeHandlers_authHandlers_loginAccountHandler;
  "functions/routeHandlers/authHandlers/resendVerificationHandler": typeof functions_routeHandlers_authHandlers_resendVerificationHandler;
  "functions/routeHandlers/authHandlers/resetPasswordHandler": typeof functions_routeHandlers_authHandlers_resetPasswordHandler;
  "functions/routeHandlers/authHandlers/sendPasswordResetHandler": typeof functions_routeHandlers_authHandlers_sendPasswordResetHandler;
  "functions/routeHandlers/authHandlers/verifyEmailCodeHandler": typeof functions_routeHandlers_authHandlers_verifyEmailCodeHandler;
  "functions/routeHandlers/authHandlers/verifyPasswordResetCodeHandler": typeof functions_routeHandlers_authHandlers_verifyPasswordResetCodeHandler;
  "functions/routeHandlers/classesHandlers/addClassHandler": typeof functions_routeHandlers_classesHandlers_addClassHandler;
  "functions/routeHandlers/classesHandlers/deleteClassHandler": typeof functions_routeHandlers_classesHandlers_deleteClassHandler;
  "functions/routeHandlers/classesHandlers/editClassHandler": typeof functions_routeHandlers_classesHandlers_editClassHandler;
  "functions/routeHandlers/classesHandlers/getTeacherClassesHandler": typeof functions_routeHandlers_classesHandlers_getTeacherClassesHandler;
  "functions/routeHandlers/fileHandlers/generateUploadUrlHandler": typeof functions_routeHandlers_fileHandlers_generateUploadUrlHandler;
  "functions/routeHandlers/subjectsHandlers/addSubjectsHandler": typeof functions_routeHandlers_subjectsHandlers_addSubjectsHandler;
  "functions/routeHandlers/subjectsHandlers/deleteSubjectHandler": typeof functions_routeHandlers_subjectsHandlers_deleteSubjectHandler;
  "functions/routeHandlers/subjectsHandlers/editSubjectHandler": typeof functions_routeHandlers_subjectsHandlers_editSubjectHandler;
  "functions/routeHandlers/subjectsHandlers/getClassSubjectsHandler": typeof functions_routeHandlers_subjectsHandlers_getClassSubjectsHandler;
  "functions/routeHandlers/teachersHandlers/getTeacherDetailsHandler": typeof functions_routeHandlers_teachersHandlers_getTeacherDetailsHandler;
  "functions/schemeOfWork/addSchemeOfWork": typeof functions_schemeOfWork_addSchemeOfWork;
  "functions/schemeOfWork/parseAndExtractTopicsAction": typeof functions_schemeOfWork_parseAndExtractTopicsAction;
  "functions/subjects/addSubjects": typeof functions_subjects_addSubjects;
  "functions/subjects/deleteSubject": typeof functions_subjects_deleteSubject;
  "functions/subjects/editSubject": typeof functions_subjects_editSubject;
  "functions/subjects/getClassSubjects": typeof functions_subjects_getClassSubjects;
  "functions/teachers/getTeacherDetails": typeof functions_teachers_getTeacherDetails;
  http: typeof http;
  myFunctions: typeof myFunctions;
  "utils/code": typeof utils_code;
  "utils/resend": typeof utils_resend;
  "utils/text": typeof utils_text;
  "utils/validation": typeof utils_validation;
}>;
declare const fullApiWithMounts: typeof fullApi;

export declare const api: FilterApi<
  typeof fullApiWithMounts,
  FunctionReference<any, "public">
>;
export declare const internal: FilterApi<
  typeof fullApiWithMounts,
  FunctionReference<any, "internal">
>;

export declare const components: {};
