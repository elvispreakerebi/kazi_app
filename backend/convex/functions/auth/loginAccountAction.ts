"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";
import { api } from "../../_generated/api";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

interface TeacherDoc {
  _id: string;
  email: string;
  name?: string;
  createdAt: number;
  language: "english" | "french" | "kiryanwanda";
  hashedPassword?: string;
  lastLogin?: number;
  googleId?: string;
}

export const loginAccountAction = action({
  args: {
    email: v.string(),
    password: v.string(),
  },
  handler: async (ctx, args): Promise<{ token: string | null }> => {
    // 1. Find teacher by email
    const user: TeacherDoc | null = await ctx.runQuery(api.functions.auth.findTeacherByEmail.findTeacherByEmail, { email: args.email });
    if (!user || !user.hashedPassword) {
      return { token: null };
    }
    // 2. Check password
    const passwordOk: boolean = await bcrypt.compare(args.password, user.hashedPassword);
    if (!passwordOk) {
      return { token: null };
    }
    // 3. Issue JWT
    const payload: Record<string, any> = {
      teacherId: user._id,
      email: user.email,
      name: user.name,
      language: user.language,
    };
    const secret: string = process.env.JWT_SECRET || "FAKE_SECRET_MUST_REPLACE";
    const token: string = jwt.sign(payload, secret, { expiresIn: "7d" });
    return { token };
  },
});
