import { mutation } from 'convex/server';
import { Id } from 'convex/values';

// Upload file and store reference in files table
export const uploadFile = mutation(async ({ db }, {
  ownerId, path, type
}: { ownerId: Id<'teachers'>, path: string, type: 'curriculum' | 'scheme' }) => {
  const uploadedAt = Date.now();
  const file = await db.insert('files', { ownerId, path, type, uploadedAt });
  return file;
});

// Parse file content and save in curriculum or schemeOfWork
export const parseAndSaveFile = mutation(async ({ db }, {
  fileId,
  entityType, // 'curriculum' or 'schemeOfWork'
  entityId,
  rawContent // (Optional) provide parsed content (stub)
}: { fileId: Id<'files'>, entityType: 'curriculum' | 'schemeOfWork', entityId: Id<'curriculum'> | Id<'schemeOfWork'>, rawContent?: any }) => {
  // Parse file logic goes here (PDF/DOCX parsing stub)
  // Save structured data to target entity
  if (entityType === 'curriculum') {
    await db.patch('curriculum', entityId as Id<'curriculum'>, { fileId, parsedContent: rawContent });
  } else if (entityType === 'schemeOfWork') {
    await db.patch('schemeOfWork', entityId as Id<'schemeOfWork'>, { fileId, parsedContent: rawContent });
  }
  return { success: true };
});
