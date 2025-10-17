import { internalAction } from "../../_generated/server";

export const internalGenerateUploadUrl = internalAction({
  args: {},
  handler: async (ctx, _args) => {
    return await ctx.storage.generateUploadUrl();
  },
});
