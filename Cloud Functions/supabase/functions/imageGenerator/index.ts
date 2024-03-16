import { RequestValidator } from "../RequestValidator.ts";
import { Supabase } from "../SupabaseClient.ts";
import { BirdWikiPage } from "../WikiPage.ts";
import { ImageGenerator } from "../findSpecies/ImageGenerator.ts";

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };
const FUNCTION_NAME = "imageGenerator";

Deno.serve(async (req) => {
  // Validation
  const validation = new RequestValidator(req);
  const validationResponse = await validation.validate();
  if (validationResponse != null) {
    Supabase.instantiate().uploadLog(FUNCTION_NAME, validation.body, validation.error);
    return validationResponse;
  };
  try {
    const wikiPage = new BirdWikiPage(validation.body.birdSpecies.toLowerCase());
    await wikiPage.setupParser();
    const description = await wikiPage.getDescription();
    const familyName = wikiPage.getBirdFamily().toUpperCase();
    const birdName = wikiPage.getBirdName();
    const imageGen = new ImageGenerator(description, familyName, birdName);
    if (validation.body.hashMap) {
      imageGen.useAlternativeColours(validation.body.hashMap);
      imageGen.generateOnlyUnisexImage();
    }
    await imageGen.generate();
    return new Response(      
      JSON.stringify({
        "bird_gen": "true"
      }),
      { headers: HEADERS,
        status: 200 },
    );
  } catch (error) {
    Supabase.instantiate().uploadLog(FUNCTION_NAME, validation.body, error.message);
    return new Response(
      JSON.stringify({error:error.message}),
      { headers: HEADERS,
        status: 500 },
    );
  }
})