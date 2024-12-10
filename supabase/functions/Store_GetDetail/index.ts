import { createClient } from "jsr:@supabase/supabase-js@2";

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
    const storeID = url.searchParams.get("storeId");
    const storeGUID = url.searchParams.get("storeGUID");

    let query = supabase.from("Store").select("*");

    if(storeID){
      query = query.eq("Id",storeID);
    }

    if(storeGUID){
      query = query.eq("GUID",storeGUID);
    }

    const { data, error } = await query;

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