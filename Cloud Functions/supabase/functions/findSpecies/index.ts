import { Supabase, BirdSpecies } from "../SupabaseClient.ts";
import { BirdAssetGenerator } from "./BirdAssetGenerator.ts";
import { findSpecies } from "./supabase_functions.ts"

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };

type FindSpeciesRequest = {
  birdSpecies: string
}

Deno.serve(async (req) => {
  // Validation
  const validation = new FindSpeciesRequestValidation(req);
  const validationResponse = await validation.validate();
  if (validationResponse != null) return validationResponse;
  try {
    // return await findSpecies(req);
    const findSpecies = new FindSpecies(validation.body.birdSpecies.toUpperCase());
    const bird = await findSpecies.getBird();
    return new Response(
      JSON.stringify("bird"),
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


class FindSpeciesRequestValidation {
  private readonly _request: Request;
  private _body!: FindSpeciesRequest;

  constructor (request: Request) {
    this._request = request;
  }

  private validatePostRequest(): boolean {
    return (this._request.method == "POST");
  }
  
  private async validateBodyRequest(): Promise<boolean> {
    this._body = await this._request.json() as FindSpeciesRequest;
    return Object.hasOwn(this._body, "birdSpecies");
  }
   
  public async validate(): Promise<Response | null> {
    if (!this.validatePostRequest()) {
      return new Response(
        JSON.stringify({
          error: "Request must be a POST"
        }),
        { headers: HEADERS,
          status: 400 },
      );
    }
    if (!(await this.validateBodyRequest())) {
      return new Response(
        JSON.stringify({
          error: "Missing birdSpecies in request body"
        }),
        { headers: HEADERS,
          status: 400 },
      );
    }
    return null;
  }

  public get body(): FindSpeciesRequest {
    return this._body;
  }
}

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
