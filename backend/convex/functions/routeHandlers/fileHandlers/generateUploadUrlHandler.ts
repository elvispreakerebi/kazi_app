export const generateUploadUrlHandler = async (ctx: any, _req: Request) => {
  const url = await ctx.storage.generateUploadUrl();
  return new Response(JSON.stringify({ url }), {
    status: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Content-Type": "application/json",
      Vary: "origin"
    }
  });
};
