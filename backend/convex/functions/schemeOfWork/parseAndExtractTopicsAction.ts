"use node";
import { action } from "../../_generated/server";
import { v } from "convex/values";

export const parseAndExtractTopicsAction = action({
  args: { schemeOfWorkId: v.id("schemeOfWork"), currentWeek: v.optional(v.number()) },
  handler: async (ctx, args) => {
    // @ts-expect-error Convex Node action - db typing
    const sow = await ctx.db.get(args.schemeOfWorkId);
    if (!sow || !sow.storageId) throw new Error("SchemeOfWork row or file missing");
    const fileBlob = await ctx.storage.get(sow.storageId);
    if (!fileBlob) throw new Error("File not found in Convex storage");
    try {
      const arrBuffer = await fileBlob.arrayBuffer();
      const buffer = Buffer.from(arrBuffer);
      // @ts-expect-error Reducto storage API file upload FormData import fallback
      const FormData = (await import('formdata-node')).FormData;
      const form = new FormData();
      const fileName = sow.path || sow.fileName || 'scheme_of_work.pdf';
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

      // Now direct field extraction using /extract
      const extractUrl = 'https://platform.reducto.ai/extract';
      const extractionPrompt = "Extract all teaching topics from this scheme of work organized by week. Return a JSON array of objects [{week: number, topic: string}], one object per week/topic. Use the week number if provided, else infer order.";
      const extractBody = JSON.stringify({
        input: `reducto://${file_id}`,
        parsing: {
          enhance: { agentic: [], summarize_figures: false },
          retrieval: {
            chunking: { chunk_mode: "disabled" },
            embedding_optimized: false,
            filter_blocks: []
          },
          formatting: {
            add_page_markers: false,
            include: [],
            merge_tables: false,
            table_output_format: "dynamic"
          },
          spreadsheet: {
            clustering: "accurate",
            exclude: [],
            include: [],
            split_large_tables: { enabled: true, size: 50 }
          },
          settings: {
            embed_pdf_metadata: false,
            force_url_result: false,
            ocr_system: "standard",
            persist_results: false,
            return_images: [],
            return_ocr_data: false,
            timeout: 900
          }
        },
        instructions: { system_prompt: extractionPrompt },
        settings: {
          include_images: false,
          optimize_for_latency: false,
          array_extract: false,
          citations: { enabled: true, numerical_confidence: true }
        }
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
      const topics: Array<{topic?: string}> = Array.isArray(extractData?.result) && extractData?.result.length ? extractData.result : [];
      const parsedContent = topics.map((r: {topic?: string}) => r.topic || '').join('\n');
      if (!topics.length) throw new Error("No topics extracted from Reducto");
      // @ts-expect-error Convex Node ctx
      await ctx.db.patch(sow._id, {
        parsedContent,
        extractedTopics: topics,
        progress: { topicsCovered: 0, totalTopics: topics.length },
        currentWeek: args.currentWeek,
      });
      return { topics, parsedLength: parsedContent.length, ok: true };
    } catch (error) {
      // @ts-expect-error Convex Node ctx
      await ctx.db.patch(sow?._id, { parsedContent: "", extractedTopics: [], progress: undefined });
      throw new Error("Failed to upload or extract SOW file: " + (error instanceof Error ? error.message : String(error)));
    }
  },
});
