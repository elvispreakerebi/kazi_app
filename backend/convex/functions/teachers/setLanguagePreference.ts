import { mutation } from "../../_generated/server";
import { v } from "convex/values";

const ALLOWED_LANGUAGES = ["english", "french", "kiryanwanda"] as const;
type AllowedLanguage = typeof ALLOWED_LANGUAGES[number];

export const setLanguagePreference = mutation({
  args: {
    teacherId: v.id("teachers"),
    language: v.string(),
  },
  handler: async (ctx, args) => {
    const lang = args.language.trim().toLowerCase() as AllowedLanguage;
    if (!ALLOWED_LANGUAGES.includes(lang)) {
      throw new Error("Invalid language: must be one of 'english', 'french', 'kiryanwanda'.");
    }
    const teacher = await ctx.db.get(args.teacherId);
    if (!teacher) throw new Error("Teacher not found.");
    await ctx.db.patch(args.teacherId, { language: lang });
    return { language: lang };
  },
});
