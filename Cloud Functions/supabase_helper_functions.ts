import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { OpenAI } from "npm:openai@4.16.1";
import Jimp from "npm:jimp";

enum GPTModels {
    gpt3="gpt-3.5-turbo-1106",
    gpt4Vision="gpt-4-vision-preview"
}

export class BirdSpeciesTable {
    public birdId: string;
    public birdName = "";
    public birdDescription = "";
    public birdScientificName = "";
    public birdFamily = "";
    public birdShapeId = "";
    public dietId = "";
    public birdImageUrl = "";
    public createdAt = "";
    public version = "0.0";
    
    constructor() {
        this.birdId = crypto.randomUUID()
    }
}

export class BirdWikiPage {
    public birdName = "";
    public birdScientificName = "";
    public birdFamily = "";
    public birdDescription = "";
    public birdDiet = "";
    public birdSummary = "";
}

export class BirdHelperFunctions {
    private _adminClient: SupabaseClient
    private _openAIClient: OpenAI
    private _version: string
    private _dietMap: Map<string, string>

    constructor (adminClient: SupabaseClient, openAiKey: string, version: string) {
        this._adminClient = adminClient;
        this._openAIClient = new OpenAI({
            apiKey: openAiKey,
        });
        this._version = version;
        this._dietMap = new Map();
    }

    public async covertFamilyToShape(familyName: string): Promise<string | null> {
        const { data, error } = await this._adminClient.from("FamilyToShape")
            .select()
            .limit(1)
            .eq("BirdFamilyName", familyName);

        if (error != null) {
            return null;
        }

        return data[0]["BirdShapeName"] as string;
    }   

    public async findDietId(dietParagraph: string): Promise<string> {
        const dietSummarySM = await this.systemMessagePrep("DietSummary");
        const diets = await this.getAllDiets();
        const dietSM = await this.systemMessagePrep("Diet", diets);

        const dietSummary = await this.askGPT(dietSummarySM, GPTModels.gpt3, dietParagraph);
        if (dietSummary == null) throw Error(`Diet summary form ${GPTModels.gpt3} failed`);
        
        const dietName = await this.askGPT(dietSM, "gpt-3.5-turbo-1106", dietSummary);
        if (dietName == null) throw Error(`Diet name form ${GPTModels.gpt3} failed`);

        const result = this._dietMap.get(dietName);
        if (result == undefined) throw Error("Could not find diet id");
        return result;
    }

    public async getSummary(paragraph: string): Promise<string> {
        const summarySM = await this.systemMessagePrep("Summary");
        const summary = await this.askGPT(summarySM, GPTModels.gpt3, paragraph);

        if (summary == undefined) throw Error("Could not generate summary");
        return summary
    }

    public async createNewImage(description: string, shapeId: string, birdName: string): Promise<string> {
        const { BirdShapeName, BirdShapeTemplateUrl, BirdShapeTemplateJson } = await this.getTemplate(shapeId);
        // const imageJson = await this.createBirdJsonTemplate(BirdShapeTemplateJson, BirdShapeTemplateUrl, description);
        const imageJson = await this.testJson();
        const colourHashMap = this.createHashMapsOfColours(imageJson, BirdShapeTemplateJson);
        const fileName = birdName.trim().replaceAll(" ", "-").toLowerCase();

        const imageTemplate: Jimp = await Jimp.read(BirdShapeTemplateUrl);
        const finalImage: Jimp = new Jimp(imageTemplate.bitmap.width, imageTemplate.bitmap.height);

        imageTemplate.scan(0,0, imageTemplate.bitmap.width, imageTemplate.bitmap.height, (x, y, idx) => {
            const pixelColourHex:number = Jimp.rgbaToInt(
                imageTemplate.bitmap.data[idx],
                imageTemplate.bitmap.data[idx+1],
                imageTemplate.bitmap.data[idx+2],
                imageTemplate.bitmap.data[idx+3],
            )
            let newPixelColourHex = colourHashMap.get(pixelColourHex);

            if(newPixelColourHex == undefined) {
                if(pixelColourHex != 0) {
                    if (pixelColourHex != 255) console.log(Jimp.intToRGBA(pixelColourHex));
                }
                newPixelColourHex = pixelColourHex;
            }

            finalImage.setPixelColor(newPixelColourHex, x, y);
        });

        this._adminClient.storage.from("BirdAssets")
            .upload(`${BirdShapeName}/${fileName}.png`, await finalImage.getBufferAsync(Jimp.MIME_PNG), {
                contentType: 'image/png'
            })
        const { data } = this._adminClient.storage.from("BirdAssets")
            .getPublicUrl(`${BirdShapeName}/${fileName}.png`)
        return data.publicUrl;
    }

    private async getTemplate(shapeId: string) {
        const { data, error } = await this._adminClient.from("BirdShape")
        .select("BirdShapeName, BirdShapeTemplateUrl, BirdShapeTemplateJson")
        .limit(1)
        .eq("BirdShapeId", shapeId);

        if (error != null) {
            throw Error("Unable to find bird shape template");
        }

        return data[0];
    }

    private createHashMapsOfColours(coloursStr: string, templateStr: object): Map<number, number> {
        const alphaValue = 255;
        const colours: Map<string, number[]> = new Map(Object.entries(JSON.parse(coloursStr)));
        const template: Map<string, number[]> = new Map(Object.entries(templateStr));
        const colourHashMap: Map<number, number> = new Map();
    
        template.forEach((templateValue, birdPart) => {
            const coloursValue: number[] | undefined = colours.get(birdPart);
    
            if(coloursValue == undefined){
                throw new Error(`Missing value: ${birdPart}`);
            }
    
            const coloursHash = Jimp.rgbaToInt(coloursValue[0], coloursValue[1], coloursValue[2], alphaValue);
            const templateColourHash = Jimp.rgbaToInt(templateValue[0], templateValue[1], templateValue[2], alphaValue);
    
            colourHashMap.set(templateColourHash, coloursHash);
        })
    
        return colourHashMap;
    }

    private async getAllDiets(): Promise<Array<string>> {
        const { data, error } = await this._adminClient.from("Diet")
            .select();

        if (error != null) {
            return [];
        }

        data.forEach((diet) => {
            this._dietMap.set(diet["DietName"], diet["DietId"])
        })
        const dietNames = data.map((dietName) => dietName["DietName"]);
        return dietNames;
    }

    private async systemMessagePrep(messageName: string, values?: Array<string> | string): Promise<string> {
        const replacementValue = "<>";
        const { data, error } = await this._adminClient.from("SystemMessages")
            .select("SystemMessageContent")
            .eq("SystemMessageName", messageName);
        
        if (error != null) {
            return "";
        }
        
        const systemMessageRaw: string = data[0]["SystemMessageContent"];

        // Just return the message if nothing in the message needs to be added
        if (values == null || !systemMessageRaw.includes(replacementValue)) {
            return data[0]["SystemMessageContent"];
        }

        switch (typeof values) {
            case "string": {
                const systemMessage = systemMessageRaw.replace("<>", values)
        
                return systemMessage;
            }
            case "object": {
                if (values.length == 0) throw new Error("Value length is 0");

                const list: string = values
                    .map((value) => value.replace(/^/, "- "))
                    .join("\n");
        
                // Replacement 
                const systemMessage = systemMessageRaw.replace("<>", list)
        
                return systemMessage;
            }
            default:
                throw Error("Unsupported type");
        }
    }

    private async askGPT(systemMessage: string, model: string, content?: string, imageUrl?: string): Promise<string | null> {
        const details: any = {
            model: model,
            messages: [{
                role: "system",
                content: [{
                    type: "text",
                    text: systemMessage
                }]
            }],
            max_tokens: 500
        }

        if(content != null) {
            details.messages.push({
                role: "user",
                content: [{
                    type: "text",
                    text: content
                }]
            })
        }

        if(imageUrl != null && model != "gpt-4-vision-preview") {
            details.messages[1].content.push({
                type: "image_url",
                image_url: imageUrl
            })
        }

        // console.log(details)
        const gptResponse = await this._openAIClient.chat.completions.create(details);
        return gptResponse.choices[0].message.content;
    }

    private async createBirdJsonTemplate(template: string, templateUrl: string, description: string): Promise<string> {
        const imageDescriptionSM = await this.systemMessagePrep("ImageDescription", template);
        const imageJson = await this.askGPT(imageDescriptionSM, GPTModels.gpt4Vision, description, templateUrl);

        if (imageJson == undefined) throw Error("Could not generate JSON");

        return imageJson;
    }

    private async testJson(): Promise<string> {
        const coloursFile = await Deno.readTextFile("testColour.json");
        return coloursFile.toString();
    }
}