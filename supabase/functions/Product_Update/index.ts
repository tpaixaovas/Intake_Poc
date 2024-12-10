import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      },
    );

    // Parse the JSON body
    const product = await req.json();

    // Update the existing product in the Product table
    const { data, error } = await supabase
      .from("Product")
      .update({
        StoreId: product.StoreId,
        Name: product.Name,
        Description: product.Description,
        Dimensions: product.Dimensions,
        Color: product.Colour,
        NumberInStock: product.NumberInStock,
        Price: product.Price,
        Discount: product.Discount,
        IsActive: product.IsActive,
        UpdatedOn: new Date(),
        UpdatedBy: product.UpdatedBy
      })
      .eq('GUID', product.GUID);

    if (error) {
      throw error;
    }

    return new Response(JSON.stringify({ data }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
