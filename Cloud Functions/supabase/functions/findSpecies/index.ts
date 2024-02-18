import { RequestValidator } from "../RequestValidator.ts";
import { Supabase, BirdSpecies } from "../SupabaseClient.ts";
import { BirdAssetGenerator } from "./BirdAssetGenerator.ts";
import { findSpecies } from "./supabase_functions.ts"

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };



Deno.serve(async (req) => {
  // Validation
  const validation = new RequestValidator(req);
  const validationResponse = await validation.validate();
  if (validationResponse != null) return validationResponse;
  try {
    const findSpecies = new FindSpecies(validation.body.birdSpecies.toUpperCase());
    const bird = await findSpecies.getBird();
    return new Response(
      JSON.stringify(bird),
      { headers: HEADERS,
        status: 200 },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({error:error.message}),
      { headers: HEADERS,
        status: 500 },
    );
  }
})

class FindSpecies {
  private readonly _requestBirdName: string;

  constructor(requestBirdName: string) {
    this._requestBirdName = requestBirdName;
  }

  private async getGeneratedBird(): Promise<BirdSpecies | null> {
    return await Supabase.instantiate().fetchBirdSpecies(this._requestBirdName);
  }

  private async generateBird(): Promise<BirdSpecies> {
    const generator: BirdAssetGenerator = new BirdAssetGenerator(this._requestBirdName);
    await generator.setupGenerator();
    await generator.generate();
    return generator.generatedBird;
  }

  public async getBird(): Promise<BirdSpecies> {
    const generatedBird: BirdSpecies | null = await this.getGeneratedBird();
    if (generatedBird == null) {
      return await this.generateBird();
    }
    return generatedBird;
  }
}
