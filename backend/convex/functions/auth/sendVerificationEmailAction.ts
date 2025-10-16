"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { generate6DigitCode } from "../../utils/code";
import { validateEmail, ValidationError } from "../../utils/validation";
import { sendEmail } from '../../utils/resend';

export const sendVerificationEmailAction = action({
  args: { email: v.string(), name: v.optional(v.string()) },
  handler: async (ctx, args): Promise<{ ok: boolean; error?: string }> => {
    try {
      validateEmail(args.email);
    } catch (err: any) {
      if (err instanceof ValidationError) {
        return { ok: false, error: err.message };
      }
      return { ok: false, error: "Unexpected error validating email." };
    }

    const teachers = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: args.email });
    if (!teachers) {
      return { ok: false, error: "No teacher/account found with this email." };
    }
    const code = generate6DigitCode();
    const now = Date.now();

    const CODE_RESEND_INTERVAL_MS = 90 * 1000;
    if (teachers.verificationCodeCreatedAt && Date.now() - teachers.verificationCodeCreatedAt < CODE_RESEND_INTERVAL_MS) {
      return { ok: false, error: "Please wait before requesting another code." };
    }

    // Save code+timestamp to teacher (must use a mutation)
    await ctx.runMutation(api.functions.auth._patchTeacherVerification._patchTeacherVerification, {
      teacherId: teachers._id,
      code,
      now,
    });
    // --- Send with Resend ---
    const subject = 'Your Kazi App Verification Code';
    const codeHtml = `<div style="font-family:Helvetica,Arial,sans-serif;font-size:16px; color:#222">
      <p>Hi ${args.name || teachers.name || args.email.split("@")[0]},</p>
      <p>Thank you for registering for the Kazi App!</p>
      <p>Your one-time verification code is</p>
      <div style="font-size: 2rem; letter-spacing: 8px; font-weight: bold; margin: 16px 0;">${code}</div>
      <p>This code will expire in 15 minutes.</p>
      <p>If you didn't request this, you can safely ignore this email.</p>
      <br/>
      <div style="color:#888; font-size:13px">Best regards,<br/>The Kazi App Team</div></div>`;
    const codeText = `Hi ${args.name || teachers.name || args.email.split("@")[0]},\n\nYour Kazi App verification code: ${code}.\nThis code will expire in 15 minutes. If you didn't request this, just ignore this email.`;
    try {
      await sendEmail({ to: args.email, subject, html: codeHtml, text: codeText });
      return { ok: true };
    } catch (err) {
      return { ok: false, error: err instanceof Error ? err.message : String(err) };
    }
  },
});
