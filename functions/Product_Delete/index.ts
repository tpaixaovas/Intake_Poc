import { createClient } from "jsr:@supabase/supabase-js@2";
import { priceWithDiscount } from "../utils.ts";

Deno.serve(async (_req) => {
  const url = new URL(_req.url);
  const productId = url.searchParams.get("productId");
  const productGuid = url.searchParams.get("productGuid");
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    {
      global: {
        headers: { Authorization: _req.headers.get("Authorization")! },
      },
    },
  );

  let query = supabase.from("Product").delete();

  if (productId) {
    query = query.eq("ID", productId);
  }

  if (productGuid) {
    query = query.eq("GUID", productGuid);
  }

  const { data, error } = await query;

  if (error) {
    return new Response(String(error?.message ?? error), { status: 500 });
  }

  return new Response("Deleted with success", { status: 200 });
});
