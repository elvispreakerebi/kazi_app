import { mutation, query } from 'convex/server';
import { Doc, database } from 'convex/schema';
import { Id } from 'convex/values';

// Registration logic for email/password
export const register = mutation(async ({ db }, {
  email,
  password
}: { email: string; password: string }) => {
  // Normally, hash the password (placeholder below)
  const passwordHash = 'HASHED_' + password; // Replace with bcrypt in prod
  // Check if email exists
  const existing = await db.query('teachers').filter(q => q.eq(q.field('email'), email)).first();
  if (existing) {
    throw new Error('User with that email already exists');
  }
  const createdAt = Date.now();
  const teacher = await db.insert('teachers', {
    email,
    passwordHash,
    createdAt,
  });
  // Return minimal info: id, email
  return { id: teacher.id, email: teacher.email };
});

// Login logic for email/password
export const login = query(async ({ db }, {
  email,
  password
}: { email: string; password: string }) => {
  // Find teacher
  const teacher = await db.query('teachers').filter(q => q.eq(q.field('email'), email)).first();
  if (!teacher) throw new Error('Invalid credentials');
  // Compare passwordHash (placeholder)
  if (teacher.passwordHash !== 'HASHED_' + password) {
    throw new Error('Invalid credentials');
  }
  // Optionally update lastLogin
  await db.patch('teachers', teacher.id, { lastLogin: Date.now() });
  // Return session token or teacher info
  return { id: teacher.id, email: teacher.email };
});

// Google auth: receive Google ID/email; upsert teacher
export const googleAuth = mutation(async ({ db }, {
  googleId,
  email
}: { googleId: string; email: string }) => {
  // Verify with Google (placeholder)
  if (!googleId || !email) throw new Error('Missing info from Google');
  // Upsert
  let teacher = await db.query('teachers').filter(q => q.eq(q.field('googleId'), googleId)).first();
  if (!teacher) {
    teacher = await db.insert('teachers', {
      email,
      googleId,
      createdAt: Date.now(),
    });
  }
  return { id: teacher.id, email: teacher.email };
});
