/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as functions_auth_createAccount from "../functions/auth/createAccount.js";
import type * as functions_auth_createAccountAction from "../functions/auth/createAccountAction.js";
import type * as functions_auth_findTeacherByEmail from "../functions/auth/findTeacherByEmail.js";
import type * as functions_auth_loginAccountAction from "../functions/auth/loginAccountAction.js";
import type * as http from "../http.js";
import type * as myFunctions from "../myFunctions.js";
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
  "functions/auth/createAccount": typeof functions_auth_createAccount;
  "functions/auth/createAccountAction": typeof functions_auth_createAccountAction;
  "functions/auth/findTeacherByEmail": typeof functions_auth_findTeacherByEmail;
  "functions/auth/loginAccountAction": typeof functions_auth_loginAccountAction;
  http: typeof http;
  myFunctions: typeof myFunctions;
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
