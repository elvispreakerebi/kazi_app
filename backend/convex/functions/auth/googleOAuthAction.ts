"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { getGoogleAuthUrl, getGoogleUser } from "./googleAuth";
import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";

const jwtSecret = process.env.JWT_SECRET || "FAKE_SECRET_MUST_REPLACE";

const clientId = process.env.GOOGLE_CLIENT_ID!;
const oAuth2Client = new OAuth2Client(clientId);

export const generateGoogleAuthUrl = action({
  args: {},
  handler: async () => {
    return { url: getGoogleAuthUrl() };
  }
});

export const handleGoogleCallback = action({
  args: { code: v.string() },
  handler: async (ctx, args): Promise<{ token?: string; deepLink?: string; error?: string }> => {
    try {
      const googleUser = await getGoogleUser(args.code);
      if (!googleUser.email) {
        return { error: "Google account has no email." };
      }
      let teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: googleUser.email });
      if (!teacher) {
        await ctx.runMutation(api.functions.auth.createAccount.createAccount, {
          email: googleUser.email,
          name: googleUser.name || googleUser.email.split("@")[0],
          hashedPassword: "", // Only for Google accounts
        });
        teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: googleUser.email });
      }
      if (!teacher) {
        return { error: "Failed to create or load teacher." };
      }
      const payload = {
        teacherId: teacher._id,
        email: googleUser.email,
        name: googleUser.name,
        provider: "google",
      };
      const token = jwt.sign(payload, jwtSecret, { expiresIn: "7d" });
      const deepLink = `kazi://auth-success?token=${encodeURIComponent(token)}`;
      return { token, deepLink };
    } catch (err: any) {
      return { error: err.message || String(err) };
    }
  }
});

const clientIds = [
  process.env.GOOGLE_CLIENT_ID_IOS!,
  process.env.GOOGLE_CLIENT_ID_ANDROID!,
];

export const handleGoogleIdTokenLogin = action({
  args: { idToken: v.string(), name: v.optional(v.string()) },
  handler: async (ctx, args): Promise<{ token?: string; error?: string }> => {
    try {
      // Verify ID token with Google (accept both iOS and Android client IDs as audience)
      const ticket = await oAuth2Client.verifyIdToken({
        idToken: args.idToken,
        audience: clientIds,
      });
      const payload = ticket.getPayload();
      if (!payload || !payload.email) {
        return { error: "Failed to get Google user info from id token." };
      }
      let teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: payload.email });
      if (!teacher) {
        await ctx.runMutation(api.functions.auth.createAccount.createAccount, {
          email: payload.email,
          name: args.name || payload.name || payload.email.split("@")[0],
          hashedPassword: "", // For Google accounts
        });
        teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: payload.email });
      }
      if (!teacher) {
        return { error: "Failed to create or load teacher." };
      }
      const jwtPayload = {
        teacherId: teacher._id,
        email: payload.email,
        name: teacher.name,
        provider: "google",
      };
      const token = jwt.sign(jwtPayload, jwtSecret, { expiresIn: "7d" });
      return { token };
    } catch (err: any) {
      return { error: err.message || String(err) };
    }
  },
});
