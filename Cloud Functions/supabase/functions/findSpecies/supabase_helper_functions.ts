import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import OpenAI from 'https://deno.land/x/openai@v4.16.1/mod.ts';
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';

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
    public birdSimulationInfo = {};
    
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
        const imageJson = await this.createBirdJsonTemplate(BirdShapeTemplateJson, BirdShapeTemplateUrl, description);
        const checkForMarkdown = imageJson.replace("```json", "").replace("```", "").trim();
        console.log(checkForMarkdown);
        const colourHashMap = this.createHashMapsOfColours(checkForMarkdown, BirdShapeTemplateJson);
        const fileName = birdName.trim().replaceAll(" ", "-").toLowerCase();
        const imageTemplateBuffer = await fetch(BirdShapeTemplateUrl).then(result => result.arrayBuffer()) as Buffer;
        const imageTemplate = await Image.decode(imageTemplateBuffer);
        const finalImage: Image = new Image(imageTemplate.width, imageTemplate.height);

        for(let x = 1; x <= imageTemplate.width; x++) {
            for(let y = 1; y <= imageTemplate.height; y++) {
                const colourValue = imageTemplate.getPixelAt(x,y);
                let newPixelColourHex = colourHashMap.get(colourValue);

                if(newPixelColourHex == undefined) {
                    // Print the colour that missing but don't print transparent values or the colour black since those will never be in the colour map
                    if(colourValue != 0) {
                        if (colourValue != 255) console.log(Image.colorToRGBA(colourValue));
                    }
                    // Leave the colour as is in case the value wasn't found
                    newPixelColourHex = colourValue;
                }
                finalImage.setPixelAt(x, y, newPixelColourHex);
            }
        }

        this._adminClient.storage.from("BirdAssets")
            .upload(`${BirdShapeName}/${fileName}.png`, await finalImage.encode(), {
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

        const result = data[0];


        return result;
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
    
            const coloursHash = Image.rgbaToColor(coloursValue[0], coloursValue[1], coloursValue[2], alphaValue);
            const templateColourHash = Image.rgbaToColor(templateValue[0], templateValue[1], templateValue[2], alphaValue);
    
            colourHashMap.set(templateColourHash, coloursHash);
        })
    
        console.log(colourHashMap);
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
                if ((values instanceof Array)) {
                    if (values.length == 0) throw new Error("Value length is 0");

                    const list: string = values
                        .map((value) => value.replace(/^/, "- "))
                        .join("\n");
            
                    // Replacement 
                    const systemMessage = systemMessageRaw.replace("<>", list);
                    return systemMessage;
                }

                const json = JSON.stringify(values);
                const removedValues = json.replaceAll(/\[(?:[0-9]+,?)+\]/g, " ");
                const systemMessage = systemMessageRaw.replace("<>", removedValues);
        
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
            max_tokens: 700
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
        const imageDescriptionSM = await this.systemMessagePrep("BodyDescription", template);
        console.log(imageDescriptionSM);
        const imageJson = await this.askGPT(imageDescriptionSM, GPTModels.gpt4Vision, description, templateUrl);

        if (imageJson == undefined) throw Error("Could not generate JSON");

        return imageJson;
    }

    public async summariseDescription(text: string[]): Promise<string> {
        const result: string[] = [];
        for(let i = 0; i< text.length; i++) {
            const summary = await this.getSummary(text[0])
            result.push(summary);
        }

        console.log(`Reduced block of text by ${(result.join().length/text.length)*100}%`)

        return result.join()
    }
}

async function fetchText(url: string | URL): Promise<string> {
    const result = await fetch(url);
    return await result.text();
}
export const _webFunctions = { fetchText }