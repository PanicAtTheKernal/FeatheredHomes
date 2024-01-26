// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';
import { decodeBase64 } from "https://deno.land/std@0.213.0/encoding/base64.ts"

const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY") as string;
const SUPABASE_URL = Deno.env.get("HOST_URL") as string;

Deno.serve(async (req) => {
  const supabaseAdminClient = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY
  );
  
  const data = await req.arrayBuffer();

  console.log(data)

  try {
    // const imageBuffer: Uint8Array = decodeBase64(data)
    await supabaseAdminClient.storage.from("BirdAssets")
    .upload(`Test.jpg`, data, { contentType: "image/jpeg" }).catch(e => console.log(e))
    const storageStuff = await supabaseAdminClient.storage.from("BirdAssets")
      .getPublicUrl(`Test.jpe`)
    console.log(storageStuff.data.publicUrl)
    } catch (error) {
    console.log(error)
  }


  return new Response(
    JSON.stringify("test"),
    { headers: { "Content-Type": "application/json" } },
  )
})
