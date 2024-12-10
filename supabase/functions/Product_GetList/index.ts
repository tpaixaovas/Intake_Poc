import { createClient } from "jsr:@supabase/supabase-js@2";
import { priceWithDiscount } from "../utils.ts";

Deno.serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    {
      global: {
        headers: { Authorization: _req.headers.get("Authorization")! },
      },
    },
  );

  const { data, error } = await supabase.from("Product").select("*");

  if (error) {
    return new Response(String(error?.message ?? error), { status: 500 });
  }

  if (data) {
    // Calculate the discounted price for each product
    const updatedData = data.map((product: any) => ({
      ...product,
      DiscountedPrice: priceWithDiscount(product.Price, product.Discount),
    }));

    return new Response(JSON.stringify({ data: updatedData }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  }
  return new Response("No data found", { status: 404 });
});
