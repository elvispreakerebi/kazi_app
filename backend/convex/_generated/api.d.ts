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
