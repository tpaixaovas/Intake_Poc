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

    // Insert the new product into the Product table
    const { data, error } = await supabase
      .from("Product")
      .insert([
        {
          StoreId: product.StoreId,
          Name: product.Name,
          Description: product.Description,
          Dimensions: product.Dimensions,
          Color: product.Color,
          NumberInStock: product.NumberInStock,
          Price: product.Price,
          Discount: product.Discount,
          IsActive: product.IsActive,
          UpdatedOn: new Date(),
          CreatedBy: product.CreatedBy,
          UpdatedBy: product.CreatedBy
        }
      ]);

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
