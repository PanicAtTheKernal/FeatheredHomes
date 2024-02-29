import { LabelSorter, SortedLabels } from "../LabelSorter.ts";
import { RequestValidator } from "../RequestValidator.ts";
import { Supabase } from "../SupabaseClient.ts";

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };
const FUNCTION_NAME = "search";
type SearchResponse = {
  isValid: boolean
  speciesName?: string,
}

Deno.serve(async (req) => {
  // Validation
  const validation = new RequestValidator(req);
  const validationResponse = await validation.validate();
  if (validationResponse != null) {
    // Supabase.instantiate().uploadLog(FUNCTION_NAME, validation.body, validation.error);
    return validationResponse;
  };
  try {
    const findSpecies = new Search(validation.body.birdSpecies.toUpperCase());
    const bird = await findSpecies.findBird();
    // Supabase.instantiate().uploadLog(FUNCTION_NAME, validation.body);
    return new Response(
      JSON.stringify(bird),
      { headers: HEADERS,
        status: 200 },
    );
  } catch (error) {
    // Supabase.instantiate().uploadLog(FUNCTION_NAME, validation.body, error.message);
    return new Response(
      JSON.stringify({error:error.message}),
      { headers: HEADERS,
        status: 500 },
    );
  }
})

export class Search {
  private readonly birdName: string;
  private readonly _labelSoter: LabelSorter;

  constructor(birdName: string) {
    this.birdName = birdName
    this._labelSoter = new LabelSorter();
  }

  public async findBird(): Promise<SearchResponse> {
    await this._labelSoter.sort(["Bird",this.birdName]);
    const sortedLabels: SortedLabels = this._labelSoter.sortedLabels;
    console.log(sortedLabels)
    if (sortedLabels.birdFamilyLabels.length == 0 && sortedLabels.birdSpeciesLabels.length == 0) {
      return {
        isValid: false
      }
    }
    if(sortedLabels.birdSpeciesLabels.length == 0) {
      const defaultBirdName = await Supabase.instantiate().fetchDefaultBirdName(sortedLabels.birdFamilyLabels[0]);
      return {
        speciesName: defaultBirdName,
        isValid: true,
      } 
    }
    return {
      speciesName: sortedLabels.birdSpeciesLabels[0],
      isValid: true,
    }
  }
}