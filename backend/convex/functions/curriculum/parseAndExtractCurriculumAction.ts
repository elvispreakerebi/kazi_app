"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";

export const parseAndExtractCurriculumAction = action({
  args: { curriculumId: v.id("curriculum") },
  handler: async (ctx, args) => {
    // @ts-expect-error Convex Node action - db typing
    const curriculum = await ctx.db.get(args.curriculumId);
    if (!curriculum || !curriculum.fileId) throw new Error("Curriculum row or file missing");
    const fileBlob = await ctx.storage.get(curriculum.fileId);
    if (!fileBlob) throw new Error("File not found in Convex storage");
    try {
      const arrBuffer = await fileBlob.arrayBuffer();
      const buffer = Buffer.from(arrBuffer);
      // @ts-expect-error Reducto storage API file upload FormData import fallback
      const FormData = (await import('formdata-node')).FormData;
      const form = new FormData();
      const fileName = 'curriculum.pdf';
      form.append('file', buffer, fileName);
      // Upload to Reducto
      const uploadUrl = 'https://platform.reducto.ai/upload';
      const uploadRes = await fetch(uploadUrl, {
        method: 'POST',
        headers: { Authorization: `Bearer ${process.env.REDUCTO_API_KEY}` },
        body: form,
      });
      if (!uploadRes.ok) throw new Error(`Reducto upload failed: HTTP ${uploadRes.status}`);
      const uploadData = await uploadRes.json();
      const file_id = uploadData.file_id;
      // Extraction
      const extractUrl = 'https://platform.reducto.ai/extract';
      const extractionPrompt = "Extract all major sections, topics, and descriptions from this curriculum document. Return a JSON array of objects with {section?: string, topic?: string, description?: string}, one per major unit/topic/module/section.";
      const extractBody = JSON.stringify({
        input: `reducto://${file_id}`,
        instructions: { system_prompt: extractionPrompt },
        parsing: {},
        settings: {},
      });
      const extractRes = await fetch(extractUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${process.env.REDUCTO_API_KEY}`,
          "Content-Type": "application/json"
        },
        body: extractBody,
      });
      if (!extractRes.ok) throw new Error(`Reducto extraction failed: HTTP ${extractRes.status}`);
      const extractData = await extractRes.json();
      const extracted: Array<{section?: string; topic?: string; description?: string}> = Array.isArray(extractData?.result) && extractData?.result.length ? extractData.result : [];
      const parsedContent = extracted.map((r) => [r.section, r.topic, r.description].filter(Boolean).join(' - ')).join('\n');
      if (!extracted.length) throw new Error("No content extracted from Reducto");
      // @ts-expect-error Convex Node ctx
      await ctx.db.patch(curriculum._id, {
        parsedContent,
      });
      return { parsedLength: parsedContent.length, ok: true };
    } catch (error) {
      // @ts-expect-error Convex Node ctx
      await ctx.db.patch(curriculum?._id, { parsedContent: "" });
      throw new Error("Failed to upload or extract curriculum: " + (error instanceof Error ? error.message : String(error)));
    }
  },
});
