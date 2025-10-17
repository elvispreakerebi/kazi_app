import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import bcrypt from "bcryptjs";
import { validateEmail, validatePassword, ValidationError } from "../../utils/validation";

export const createAccountAction = action({
  args: {
    email: v.string(),
    password: v.string(),
    name: v.string(),
  },
  handler: async (ctx, args): Promise<{ id?: any; email?: string; error?: string }> => {
    try {
      validateEmail(args.email);
      validatePassword(args.password);
    } catch (err) {
      if (err instanceof ValidationError) {
        return { error: err.message };
      }
      throw err;
    }
    try {
      const hashedPassword: string = await bcrypt.hash(args.password, 10);
      const result: { id: any; email: string } = await ctx.runMutation(
        api.functions.auth.createAccount.createAccount,
        {
          email: args.email,
          name: args.name,
          hashedPassword,
        }
      );
      return result;
    } catch (err: any) {
      // If error message text matches 'Account already exists.'
      if (err instanceof Error && err.message && err.message.toLowerCase().includes("already exists")) {
        return { error: "An account with this email already exists." };
      }
      throw err;
    }
  },
});
