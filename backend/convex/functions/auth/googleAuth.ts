"use node";
import { OAuth2Client } from "google-auth-library";

const clientId = process.env.GOOGLE_CLIENT_ID!;
const clientSecret = process.env.GOOGLE_CLIENT_SECRET!;
const redirectUri = process.env.GOOGLE_REDIRECT_URI!;

const oAuth2Client = new OAuth2Client(clientId, clientSecret, redirectUri);

export function getGoogleAuthUrl(state = "") {
  return oAuth2Client.generateAuthUrl({
    access_type: "offline",
    scope: ["profile", "email"],
    prompt: "select_account",
    state,
  });
}

export async function getGoogleUser(code: string) {
  const { tokens } = await oAuth2Client.getToken(code);
  oAuth2Client.setCredentials(tokens);
  const ticket = await oAuth2Client.verifyIdToken({
    idToken: tokens.id_token as string,
    audience: clientId,
  });
  const payload = ticket.getPayload();
  return {
    email: payload?.email,
    name: payload?.name,
    googleId: payload?.sub,
    emailVerified: payload?.email_verified,
  };
}
