import { RequestValidator } from "../RequestValidator.ts";
import { Supabase } from "../SupabaseClient.ts";
import { BirdWikiPage } from "../WikiPage.ts";
import { ImageGeneratorLite } from "./ImageGeneratorLite.ts";

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
    const imageGen = new ImageGeneratorLite(validation.body.hashMap as Object, validation.body.shapeId as string, validation.body.birdSpecies.toLowerCase());
    await imageGen.generateImageAndUpload();
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