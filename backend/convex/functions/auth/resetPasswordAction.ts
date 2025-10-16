import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import bcrypt from "bcryptjs";
import { validatePassword } from "../../utils/validation";

export const resetPasswordAction = action({
  args: { email: v.string(), code: v.string(), newPassword: v.string() },
  handler: async (ctx, args): Promise<{ ok: boolean; error?: string }> => {
    try { validatePassword(args.newPassword); } catch (err: any) { return { ok: false, error: err.message }; }
    const teacher = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: args.email });
    if (!teacher || !teacher.passwordResetCode || !teacher.passwordResetCodeCreatedAt) {
      return { ok: false, error: 'Invalid or expired reset code.' };
    }
    if (Date.now() - teacher.passwordResetCodeCreatedAt > 15 * 60 * 1000) {
      return { ok: false, error: 'Reset code expired.' };
    }
    if (teacher.passwordResetCode !== args.code) {
      return { ok: false, error: 'Invalid reset code.' };
    }
    const hashedPassword = await bcrypt.hash(args.newPassword, 10);
    await ctx.runMutation(api.functions.auth._resetTeacherPassword._resetTeacherPassword, {
      teacherId: teacher._id,
      hashedPassword,
    });
    return { ok: true };
  },
});
