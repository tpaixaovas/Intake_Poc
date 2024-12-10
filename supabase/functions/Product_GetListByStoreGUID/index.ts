import { createClient } from "jsr:@supabase/supabase-js@2";
import { priceWithDiscount } from "../utils.ts";

Deno.serve(async (_req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      {
        global: {
          headers: { Authorization: _req.headers.get("Authorization")! },
        },
      },
    );

    const url = new URL(_req.url);
    const storeGUID = url.searchParams.get("storeGUID");

    // First query to get the Store ID
    const { data: storeData, error: storeError } = await supabase
      .from("Store")
      .select("Id")
      .eq("GUID", storeGUID)
      .single();

    if (storeError) {
      throw storeError;
    }

    const storeID = storeData?.Id;

    // Second query to get the Products
    const { data: productData, error: productError } = await supabase
      .from("Product")
      .select("*")
      .eq("StoreId", storeID);

    if (productError) {
      throw productError;
    }

    if (productData) {
      // Calculate the discounted price for each product
      const updatedData = productData.map((product: any) => ({
        ...product,
        DiscountedPrice: priceWithDiscount(product.Price, product.Discount),
      }));

      return new Response(JSON.stringify({ data: updatedData }), {
        headers: { "Content-Type": "application/json" },
        status: 200,
      });
    }
  } catch (err) {
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
