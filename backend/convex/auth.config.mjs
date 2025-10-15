import { Password } from "@convex-dev/auth/providers/Password";
import Google from "@auth/core/providers/google";
import { convexAuth } from "@convex-dev/auth/server";
import { capitalizeWords } from "./utils/text.js";

export default convexAuth({
  providers: [
    Password({
      profile: (params) => ({
        email: params.email,
        name: capitalizeWords(params.name || ""),
        language: params.language || "english",
      }),
      validatePasswordRequirements: (password) => {
        if (password.length < 8) throw new Error("Password must be at least 8 characters.");
      },
    }),
    Google,
  ],
  callbacks: {
    async createOrUpdateUser(ctx, args) {
      const { profile, existingUserId } = args;
      if (existingUserId) {
        await ctx.db.patch(existingUserId, { ...profile });
        return existingUserId;
      }
      return await ctx.db.insert("users", {
        ...profile,
        createdAt: Date.now(),
      });
    },
  },
});
