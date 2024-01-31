// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { Buffer } from "node:buffer";
import { LabelSorter, SortedLabels } from "./LabelSorter.ts";
import { Supabase } from "../SupabaseClient.ts";

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };

type ImageIdentificationResponse = {
  isBird: boolean,
  birdSpecies?: string,
  approximate?: boolean,
  error?: string 
}

type LabelDetectionRequest = {
  requests: [
    {
      image: {
        content: string
      },
      features: [
        {
          maxResults: number,
          type: string
        }
      ]
    }
  ]
}

type LabelAnnotations = {
  description: string,
  mid: string,
  score: number,
  topicality: number
}

Deno.serve(async (req: Request) => {  
  try {
    const imageIdentification = new ImageIdentification(await req.arrayBuffer());
    await imageIdentification.identifyLabelsInImage();
    const response = await imageIdentification.determineIfImageHasBird();
    return new Response(
      JSON.stringify(response),
      { headers: HEADERS },
    );
  } catch(error) {
    return new Response(
      JSON.stringify({error: error.message}),
      { headers: HEADERS,
        status: 500 },
    ); 
  }
})

class LabelDetection {
  private readonly _imageBuffer: ArrayBuffer;
  private readonly _imageBase64: string;
  private readonly _maxRequest: number;
  private readonly _requestType: string;
  private readonly _googleCloudApiKey: string;
  private _response: LabelAnnotations[];

  constructor(imageBuffer: ArrayBuffer) {
    this._googleCloudApiKey = Deno.env.get("GOOGLE_CLOUD_API_KEY") as string;
    this._imageBuffer = imageBuffer;
    this._imageBase64 = this.encodeRequestIntoBase64();
    this._maxRequest = 20;
    this._requestType = "LABEL_DETECTION";
    this._response = [];
  }

  private encodeRequestIntoBase64(): string {
    const base64String = Buffer.from(this._imageBuffer).toString('base64');
    return base64String;
  }

  private prepareLabelDetectionRequest(): LabelDetectionRequest {
    return {
      requests: [
        {
          image: {
            content: this._imageBase64
          },
          features: [
            {
              maxResults: this._maxRequest,
              type: this._requestType
            }
          ]
        }
      ]
    }
  }

  public async sendLabelDetectionRequest(): Promise<void> {
    const result = await fetch("https://vision.googleapis.com/v1/images:annotate", {
      method: "POST",
      headers: {
        "X-goog-api-key": `${this._googleCloudApiKey}`,
        "Content-Type": `${CONTENT_TYPE}`
      },
      body: JSON.stringify(this.prepareLabelDetectionRequest())
    });
    const response = await result.json();
    if (response["error"] != undefined) {
      throw new Error(`Label Detection: ${response["error"]["message"]}`);
    }
    if (response["responses"][0]["labelAnnotations"] == undefined) {
      throw new Error("Label Detection: Result is missing properties");
    }
    this._response = response["responses"][0]["labelAnnotations"];
  }

  public getLabelDetectionResults(): Map<string, number> {
    const labelMap: Map<string, number> = new Map();
    this._response.map((labelAnnotation: any)=> {
      labelMap.set(labelAnnotation.description, labelAnnotation.score);
    })
    return labelMap;
  }
}

class ImageIdentification {
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

  public async determineIfImageHasBird(): Promise<ImageIdentificationResponse> {
    const labels = Array.from(this._labels.keys());
    await this._labelSoter.sort(labels);
    const sortedLabels: SortedLabels = this._labelSoter.sortedLabels;
    if(!sortedLabels.isBird && (sortedLabels.birdFamilyLabels.length == 0 && sortedLabels.birdSpeciesLabels.length == 0)) {
      return {
        isBird: false
      }
    } else if (sortedLabels.isBird && (sortedLabels.birdFamilyLabels.length == 0 && sortedLabels.birdSpeciesLabels.length == 0)) {
      return {
        isBird: false,
        error: "Couldn't detect the species of the bird. Please try to upload a clearer image."
      }
    }
    if(sortedLabels.birdSpeciesLabels.length == 0) {
      const defaultBirdName = await Supabase.instantiate().fetchDefaultBirdName(sortedLabels.birdFamilyLabels[0]);
      return {
        isBird: true,
        birdSpecies: defaultBirdName,
        approximate: true
      } 
    }
    return {
      isBird: true,
      birdSpecies: sortedLabels.birdSpeciesLabels[0],
    }
  }
}