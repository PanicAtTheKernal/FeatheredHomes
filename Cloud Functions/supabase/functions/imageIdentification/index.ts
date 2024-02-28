// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { LabelSorter, SortedLabels } from "../LabelSorter.ts";
import { Log, Supabase } from "../SupabaseClient.ts";
import { ReferralWikiPage } from "../WikiPage.ts";
import { LabelDetection } from "./LabelDetection.ts";

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };
const FUNCTION_NAME = "imageIdentification";

type ImageIdentificationResponse = {
  isBird: boolean,
  birdSpecies?: string,
  approximate?: boolean,
  error: string 
}

export const server = Deno.serve(async (req: Request) => {  
  if (req.method != "POST") {
    Supabase.instantiate().uploadLog(FUNCTION_NAME, {}, "Request must be a POST");
    return new Response(
      JSON.stringify({
        error: "Request must be a POST"
      }),
      { headers: HEADERS,
        status: 400 },
    );
  }
  try {
    const imageIdentification = new ImageIdentification(await req.arrayBuffer());
    await imageIdentification.identifyLabelsInImage();
    const birdName = await imageIdentification.getBirdName();
    const response: ImageIdentificationResponse = {
      isBird: true,
      birdSpecies: birdName.name,
      approximate: birdName.approximate,
      error: ""
    } 
    Supabase.instantiate().uploadLog(FUNCTION_NAME, response);
    return new Response(
      JSON.stringify(response),
      { headers: HEADERS },
    );
  } catch(error) {
    Supabase.instantiate().uploadLog(FUNCTION_NAME, {}, error.message);
    const response: ImageIdentificationResponse = {
      isBird: false,
      error: error.message
    } 
    return new Response(
      JSON.stringify(response),
      { headers: HEADERS,
        status: 500 },
    ); 
  }
})

export class ImageIdentification {
  private readonly _labelDetection: LabelDetection;
  private readonly _labelSoter: LabelSorter;
  private _labels: Map<string, number>;

  constructor (requestBuffer: ArrayBuffer) {
    this._labelDetection = new LabelDetection(requestBuffer);
    this._labelSoter = new LabelSorter();
    this._labels = new Map();
  }

  public async identifyLabelsInImage() {
    await this._labelDetection.sendLabelDetectionRequest();
    this._labels = this._labelDetection.getLabelDetectionResults();
  } 

  public async getBirdName(): Promise<{ name: string, approximate: boolean}> {
    const labels = Array.from(this._labels.keys());
    console.log(labels);
    await this._labelSoter.sort(labels);
    const sortedLabels: SortedLabels = this._labelSoter.sortedLabels;
    console.log(sortedLabels)
    if (sortedLabels.birdFamilyLabels.length == 0 && sortedLabels.birdSpeciesLabels.length == 0) {
      throw new Error("Blurry bird");
    }
    if(sortedLabels.birdSpeciesLabels.length == 0) {
      const defaultBirdName = await Supabase.instantiate().fetchDefaultBirdName(sortedLabels.birdFamilyLabels[0]);
      return {
        name: defaultBirdName,
        approximate: true,
      } 
    }
    return {
      name: sortedLabels.birdSpeciesLabels[0],
      approximate: false,
    }
  }
}