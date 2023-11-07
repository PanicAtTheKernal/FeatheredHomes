import {} from "./supabase_helper_functions.ts"
import { OpenAI } from "https://esm.sh/openai@4.11.1";
import { load } from "https://deno.land/std@0.202.0/dotenv/mod.ts";
import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

// Temp for local testing
const env = await load();
const SUPABASE_SERVICE_ROLE_KEY = env["SUPABASE_SERVICE_ROLE_KEY"];
const SUPABASE_URL = env["SUPABASE_URL"];
const birdSpeciesTable = "BirdSpecies";
const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Content-Type': 'application/json'
  };

async function findSpecies(request: Request): Promise<Response> {
    const requestUrl = new URL(request.url)
    const speciesName = requestUrl.searchParams.get("species");
    const nameCol = "birdName"
    const supabaseAdminClient = createClient(
        SUPABASE_URL,
        SUPABASE_SERVICE_ROLE_KEY
    );

    if (speciesName == null) {
        return new Response(JSON.stringify({ error: "Parameter 'species' is missing" }), {
            headers: headers,
            status: 400
        });
    }

    const { data, error } = await supabaseAdminClient.from(birdSpeciesTable).select().eq(nameCol, speciesName);
    
    if (error != null) {
        console.log(error)
        return new Response(JSON.stringify({ error: error.message }), {
            headers: headers,
            status: 400
        });
    }

    if (data.length == 0) {
        // TODO Call the create bird function
        await findWikiPage(speciesName);
        return new Response(JSON.stringify({ message: "Creating new bird" }), {
            headers: headers,
            status: 200
        });
    }

    return new Response(JSON.stringify({ data: data }), {
        headers: headers,
        status: 200
    });
}

async function findWikiPage(species: string): Promise<Response> {
    
    
    return new Response();
}

async function main() {
    const newRequest  = new Request("http://test.com/test?species=test", {
        headers: headers
    });
    console.log(await (await findSpecies(newRequest)).json())

    //const result = await findSpecies("tests", supabaseAdminClient);
    //console.log(result)
}

main();