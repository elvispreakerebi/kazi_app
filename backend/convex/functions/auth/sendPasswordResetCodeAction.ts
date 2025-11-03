import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import { generate6DigitCode } from "../../utils/code";
import { sendEmail } from '../../utils/resend';
import { validateEmail } from "../../utils/validation";

export const sendPasswordResetCodeAction = action({
  args: { email: v.string() },
  handler: async (ctx, args): Promise<{ ok: boolean }> => {
    // Always respond OK for privacy
    try {
      validateEmail(args.email);
    } catch {
      return { ok: true };
    }
    const teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: args.email });
    if (!teacher) return { ok: true };
    // Rate limiting: 90sec
    const now = Date.now();
    if (teacher.passwordResetCodeCreatedAt && (now - teacher.passwordResetCodeCreatedAt < 90_000)) return { ok: true };
    const code = generate6DigitCode();
    await ctx.runMutation(api.functions.auth._patchTeacherVerification._patchTeacherVerification, { // Reuse patch fn for code add
      teacherId: teacher._id,
      code,
      now,
      field: 'reset'
    });
    await sendEmail({
      to: args.email,
      subject: 'Your Password Reset Code',
      html: `<p>Hi${teacher.name ? ' ' + teacher.name : ''},<br/>Your password reset code is: <b>${code}</b> (expires in 15 minutes)</p>`,
      text: `Password reset code: ${code}`
    });
    return { ok: true };
  },
});
