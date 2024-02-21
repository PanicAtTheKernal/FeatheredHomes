import { Buffer } from "node:buffer";

const CONTENT_TYPE = "application/json; charset=utf-8";
const HEADERS = { "Content-Type": CONTENT_TYPE };

export type LabelAnnotations = {
    description: string,
    mid: string,
    score: number,
    topicality: number
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

export class LabelDetection {
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

