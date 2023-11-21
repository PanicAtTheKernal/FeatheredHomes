import { BirdSpeciesTable, BirdWikiPage, BirdHelperFunctions } from "./supabase_helper_functions.ts"
import { OpenAI } from "https://esm.sh/openai@4.11.1";
import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { DOMParser, Element, HTMLDocument } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";
import { format } from "https://deno.land/std@0.202.0/datetime/mod.ts";


// Temp for local testing
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY") as string;
const SUPABASE_URL = Deno.env.get("HOST_URL") as string;
const VERSION = Deno.env.get("VERSION") as string;
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") as string;
const birdSpeciesTable = "BirdSpecies";
const nameCol = "birdName"
const pontentialDietHeadings = ["Diet", "Behaviour and ecology", "Diet and feeding"];
const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Content-Type': 'application/json'
  };

export async function findSpecies(request: Request): Promise<Response> {
    const requestUrl = new URL(request.url)
    const speciesName = requestUrl.searchParams.get("species")?.toLowerCase();
    const supabaseAdminClient: SupabaseClient = createClient(
        SUPABASE_URL,
        SUPABASE_SERVICE_ROLE_KEY
    );

    if (speciesName == null) {
        return new Response(JSON.stringify({ error: "Parameter 'species' is missing" }), {
            headers: headers,
            status: 400
        });
    }

    const { data, error } = await supabaseAdminClient.from(birdSpeciesTable).select().like(nameCol, `%${speciesName}%`);
    
    if (error != null) {
        console.log(error);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: headers,
            status: 400
        });
    }

    if (data.length == 0) {
        return await findWikiPage(speciesName, supabaseAdminClient);
    }

    return new Response(JSON.stringify({ data: data[0] }), {
        headers: headers,
        status: 200
    });
}

async function findWikiPage(species: string, client: SupabaseClient): Promise<Response> {
    const wikiSearchEndpoint = new URL("https://en.wikipedia.org/w/api.php");
    wikiSearchEndpoint.searchParams.append("origin", "*");
    wikiSearchEndpoint.searchParams.append("action", "opensearch");
    wikiSearchEndpoint.searchParams.append("search", species);
    wikiSearchEndpoint.searchParams.append("limit", "1");
    wikiSearchEndpoint.searchParams.append("namespace", "0");
    wikiSearchEndpoint.searchParams.append("format", "json");

    const searchRequest = await fetch(wikiSearchEndpoint);
    const searchBody =  await searchRequest.json();
    const urls: Array<string> = searchBody[3];

    if (urls.length == 0) {
        return new Response(JSON.stringify({ error: `"${species}" was not found` }), {
            headers: headers,
            status: 404
        });
    }

    // console.log(searchBody);
    const speciesUrl: URL = new URL(urls[0]);
    return await parseWikiPage(speciesUrl, client);
}

async function parseWikiPage(speciesUrl: URL, client: SupabaseClient): Promise<Response> {
    const wikiPageResult = await fetch(speciesUrl);
    const wikiPageBody = await wikiPageResult.text();
    const domParser = new DOMParser();
    const newBirdInfo: BirdWikiPage = new BirdWikiPage();
    const content: HTMLDocument | null = domParser.parseFromString(wikiPageBody, "text/html");
    
    if (content == null) {
        return new Response(JSON.stringify({ error: "Unable to get HTML body" }), {
            headers: headers,
            status: 501
        });
    }
    
    newBirdInfo.birdName = content.body.getElementsByClassName("mw-page-title-main")[0].innerText;

    const infoBox = content.body.getElementsByClassName("infobox biota")[0].innerText.replaceAll("\n", " ");
    // Get bird family
    const familyNameResult = infoBox.match(/Family:\s+([a-zA-Z]+)/);

    if (familyNameResult == null) {
        return new Response(JSON.stringify({ error: "Unable to find family name" }), {
            headers: headers,
            status: 501
        });
    }

    newBirdInfo.birdFamily = familyNameResult[1];

    // Get bird scientific name
    const scientificNameResult = infoBox.match(/Binomial name\s+([a-zA-Z ]+)/);

    if (scientificNameResult == null) {
        return new Response(JSON.stringify({ error: "Unable to find scientific name" }), {
            headers: headers,
            status: 501
        });
    }

    newBirdInfo.birdScientificName = scientificNameResult[1];

    const wikiTextHtml = content.body.getElementsByClassName("mw-content-ltr")[0];

    // Remove infobox if exits
    if (wikiTextHtml.getElementsByClassName("infobox biota").length > 0) {
        wikiTextHtml.getElementsByClassName("infobox biota")[0].remove();
    }

    // Remove any non p tag from the top of the wiki page. It doesn't 
    while (wikiTextHtml.firstElementChild?.tagName != "P") {
        wikiTextHtml.firstElementChild?.remove();
    }

    const referencesIndex = wikiTextHtml.innerText.indexOf("References");
    const wikiText = wikiTextHtml.innerText.substring(0, referencesIndex).trim()
    const paragraphs: Map<string, string> = new Map();
    let lastIndex = 0;

    const headings = wikiTextHtml.getElementsByTagName("H2");
    const headings2 = wikiTextHtml.getElementsByTagName("H3");
    // const headingResults = wikiText.match(/\n([a-zA-Z ]+)\[edit\]\n/g)
    let headingResults = headings.map(header => header.innerText)
    const headingResults2 = headings2.map(header => header.innerText);

    // Remove references from the headings
    const referenceIndex = headingResults.indexOf("References")
    headingResults.splice(referenceIndex, headingResults.length - referenceIndex);

    // Merge heading together
    headingResults = headingResults.concat(headingResults2)


    if (headingResults == null) {
        return new Response(JSON.stringify({ error: "Unable to parse wiki" }), {
            headers: headers,
            status: 501
        });
    }

    headingResults.unshift("\nSummary[edit]\n");
    for (let i = 0; i < headingResults.length-1; i++) {
        const index = wikiText.indexOf(headingResults[i+1])
        const paragraph = wikiText.substring(lastIndex, index)
            .replace(headingResults[i], "")
            .replaceAll(/\[[0-9]+\]/g, "")
            .replaceAll("\n", " ")
            .trim();
        const trimmedHeading = headingResults[i].trim().replace("[edit]", "")
        paragraphs.set(trimmedHeading, paragraph);
        lastIndex = index;
    }

    const pontentialDietHeading = pontentialDietHeadings.find((value) => {
        const data = paragraphs.get(value);
        if (data != undefined) {
            return data;
        }
    }) as string

    newBirdInfo.birdDescription = paragraphs.get("Description") as string
    newBirdInfo.birdDiet = paragraphs.get(pontentialDietHeading) as string
    newBirdInfo.birdSummary = paragraphs.get("Summary") as string

    console.log(newBirdInfo);

    // Call the staging function
    return await stageData(newBirdInfo, client);
}

async function stageData(wikiPageInfo: BirdWikiPage, client: SupabaseClient): Promise<Response> {
    const helperFunctions: BirdHelperFunctions = new BirdHelperFunctions(client, OPENAI_API_KEY, VERSION);
    const newSpecies: BirdSpeciesTable = new BirdSpeciesTable()
    const date = new Date();

    try {
        const shapeId = await helperFunctions.covertFamilyToShape(wikiPageInfo.birdFamily) as string;
        const dietId = await helperFunctions.findDietId(wikiPageInfo.birdDiet);

        newSpecies.birdName = wikiPageInfo.birdName.toLowerCase();
        newSpecies.birdDescription = await helperFunctions.getSummary(wikiPageInfo.birdSummary);
        // newSpecies.birdDescription = "Test summary"
        newSpecies.birdScientificName = wikiPageInfo.birdScientificName;
        newSpecies.birdFamily = wikiPageInfo.birdFamily;
        newSpecies.birdShapeId = shapeId
        newSpecies.dietId = dietId
        // newSpecies.dietId = "5bd828f0-805a-4fd0-90a5-039294930d7f"
        newSpecies.birdImageUrl = await helperFunctions.createNewImage(wikiPageInfo.birdDescription, shapeId, wikiPageInfo.birdName);
        newSpecies.version = VERSION;
        // Have to offset month by 1 since data.getMonth returns the values between 0-11 and not 1-12
        newSpecies.createdAt = `${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}.${date.getMilliseconds()}`
        newSpecies.birdSimulationInfo = {
            "birdRange": 90,
            "birdStamina": 2000,
            "birdTakeOffCost": 100,
            "birdGroundCost": 50,
            "birdFlightCost": 20,
            "birdMaxStamina": 4000,
            "birdTraits": ["Can't walk long distances"]
        }

        const response = await client.from(birdSpeciesTable).insert(newSpecies);

        if (response.error) throw response.error;

        const { data, error } = await client.from(birdSpeciesTable).select().eq("birdId", newSpecies.birdId);

        if (error) throw error;

        return new Response(JSON.stringify({ data: data[0] }), {
            headers: headers,
            status: 200
        });
    } catch (error) {
        console.log(error)

        return new Response(JSON.stringify({ error: error.toString() }), {
            headers: headers,
            status: 501
        });
    }
}