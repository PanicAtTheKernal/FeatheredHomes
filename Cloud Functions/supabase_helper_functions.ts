import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { OpenAI } from "npm:openai@4.16.1";

enum GPTModels {
    gpt3="gpt-3.5-turbo-1106"
}

export class BirdSpeciesTable {
    private _birdId: string;
    public birdName: string;
    public birdDescription: string;
    public birdScientificName: string;
    public birdFamily: string;
    public birdShapeId: string;
    public dietId: string;
    public birdImageUrl: string;
    public createdAt: number;
    public version: string;
    
    constructor() {
        this._birdId = crypto.randomUUID()
        this.birdName = "";
        this.birdDescription = "";
        this.birdScientificName = "";
        this.birdFamily = "";
        this.birdShapeId = "";
        this.dietId = "";
        this.birdImageUrl = "";
        this.createdAt = 0;
        this.version = "0.0";
    }

    public get birdId() {
        return this._birdId;
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
    private _dietMap: Map<string, string>

    constructor (adminClient: SupabaseClient, openAiKey: string) {
        this._adminClient = adminClient;
        this._openAIClient = new OpenAI({
            apiKey: openAiKey,
        });
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

    private async systemMessagePrep(messageName: string, values?: Array<string>): Promise<string> {
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

        const diets: string = values
            .map((value) => value.replace(/^/, "- "))
            .join("\n");
        if (diets.length == 0) return "";

        // Replacement 
        const systemMessage = systemMessageRaw.replace("<>", diets)

        return systemMessage;
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

    private async askGPT(systemMessage: string, model: string, content?: string, imageUrl?: string): Promise<string | null> {
        const details: any = {
            model: model,
            messages: [{
                role: "system",
                content: [{
                    type: "text",
                    text: systemMessage
                }]
            }]
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
}