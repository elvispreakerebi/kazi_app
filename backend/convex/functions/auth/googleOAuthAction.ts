"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";

const jwtSecret = process.env.JWT_SECRET || "FAKE_SECRET_MUST_REPLACE";

const clientId = process.env.GOOGLE_CLIENT_ID!;
const oAuth2Client = new OAuth2Client(clientId);

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
          googleId: payload.sub, // Only set at create time
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
