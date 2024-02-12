import OpenAI from 'npm:openai';
import { Supabase } from './SupabaseClient.ts';

export enum GPTModels {
    gpt3="gpt-3.5-turbo-0125",
    gpt4Vision="gpt-4-vision-preview",
    gpt4Turbo="gpt-4-turbo-preview"
}

export type OpenAIMessage = {
    role: string,
    content: [{
        type: string,
        text: string
    }]
}

export type OpenAIRequest = {
    model: GPTModels,
    messages: OpenAIMessage[],
    max_tokens: number
}

export type ReplacementValues = {
    placeholder: string,
    replacement: string | string[]
}

class OpenAIRequestBuilder {
    private _request!: OpenAIRequest;
    private static readonly maxTokens = 700;

    constructor() {
        this.reset();
    }

    private reset() {
        this._request = {
            model: GPTModels.gpt3,
            messages: [],
            max_tokens: OpenAIRequestBuilder.maxTokens
        }
    }

    public setGPTModel(model: GPTModels) {
        this._request.model = model
    }

    public addSystemMessage(systemMessage: string) {
        this._request.messages.push({
            role: "system",
            content: [{
                type: "text",
                text: systemMessage
            }]
        });
    }

    public replaceSystemMsgPlaceholder(replacementValues: ReplacementValues[]): void {
        if (this._request.messages[0].role != "system") {
            throw new Error("System message not set");
        }

        replacementValues.forEach((replacementValue: ReplacementValues) => {
            switch (typeof replacementValue.replacement) {
                case "string": {
                    this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replaceAll(replacementValue.placeholder, replacementValue.replacement);
                    break;
                }
                case "object": {
                    if ((replacementValues instanceof Array)) {
                        if (replacementValues.length == 0) throw new Error("Value length is 0");
    
                        const list: string = replacementValue.replacement
                            .map((replacement) => replacement.replace(/^/, "- "))
                            .join("\n");
                
                        // Replacement 
                        this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replace(replacementValue.placeholder, list);
                        break;
                    }
    
                    const json = JSON.stringify(replacementValue.replacement);
                    const removedValues = json.replaceAll(/\[(?:[0-9]+,?)+\]/g, " ");
                    this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replace(replacementValue.placeholder, removedValues);
            
                    break;
                }
                default:
                    throw Error("Unsupported type");
            };
        })
    }

    public addContent(content: string): void {
        this._request.messages.push({
            role: "user",
            content: [{
                type: "text",
                text: content
            }]
        });
    }

    public getRequest(): OpenAIRequest {
        const request = this._request;
        this.reset();
        return request;
    }
}

export class OpenAIRequestDirector {
    private _builder: OpenAIRequestBuilder;

    constructor () {
        this._builder = new OpenAIRequestBuilder();
    }

    public async setSystemMessage(systemMessageName: string) {
        const message = await Supabase.instantiate().fetchSystemMessage(systemMessageName);
        this._builder.addSystemMessage(message); 
    }

    public buildGPT3request(content: string): OpenAIRequest {
        this._builder.addContent(content);
        this._builder.setGPTModel(GPTModels.gpt3);
        return this._builder.getRequest();
    }

    public buildSummaryRequest(summary: string, focus: string): OpenAIRequest {
        const replacement: ReplacementValues = {
            placeholder: "<>",
            replacement: focus
        };
        this._builder.addContent(summary);
        this._builder.replaceSystemMsgPlaceholder([replacement]);
        this._builder.setGPTModel(GPTModels.gpt3);
        return this._builder.getRequest();
    }

    public buildColourGeneratorRequest(description: string, gender: string, bodyParts: string): OpenAIRequest {
        const genderReplacement: ReplacementValues = {
            placeholder: "<>",
            replacement: gender
        };
        const bodyPartsReplacement: ReplacementValues = {
            placeholder: "[]",
            replacement: `[${bodyParts}]`
        };
        this._builder.addContent(description);
        this._builder.setGPTModel(GPTModels.gpt4Turbo);
        this._builder.replaceSystemMsgPlaceholder([genderReplacement, bodyPartsReplacement]);
        return this._builder.getRequest();
    }

    public buildTraitGeneratorRequest(description: string, birdName: string, traits: string): OpenAIRequest {
        const birdNameReplacement: ReplacementValues = {
            placeholder: "<>",
            replacement: birdName
        };
        const traitsReplacement: ReplacementValues = {
            placeholder: "[]",
            replacement: `[${traits}]`
        };
        this._builder.addContent(description);
        this._builder.setGPTModel(GPTModels.gpt4Turbo);
        this._builder.replaceSystemMsgPlaceholder([birdNameReplacement, traitsReplacement]);
        return this._builder.getRequest();
    }
}

export class ChatGPT {
    private static _instance: ChatGPT;
    private readonly _openAIClient: OpenAI;
    private readonly _openAIApiKey: string;

    private constructor() {
        this._openAIApiKey = Deno.env.get("OPENAI_API_KEY") as string;
        this._openAIClient = new OpenAI({
            apiKey: this._openAIApiKey
        });
    }

    public static instantiate(): ChatGPT {
        if (this._instance == undefined) {
            this._instance = new ChatGPT();
        }
        return this._instance;
    }

    private async generateSummary(summary: string, focus: string, openaiDirector: OpenAIRequestDirector): Promise<string> {
        const nameExtractionRequest = openaiDirector.buildSummaryRequest(summary, focus) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(nameExtractionRequest);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the simplified bird summary");
        }
        return chatGPTResponse.choices[0].message.content;
    }

    public async checkIfSummaryIsAboutBirds(summary: string): Promise<boolean> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("BirdFilter");
        const labelFilterRequest = openAIRequestDirector.buildGPT3request(summary) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(labelFilterRequest);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the bird summary");
        }
        return (chatGPTResponse.choices[0].message.content == "True");
    }

    public async extractBirdName(text: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("BirdNameExtractor");
        const request = openAIRequestDirector.buildGPT3request(text) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(request);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the bird name extraction");
        }
        return chatGPTResponse.choices[0].message.content;
    }

    public async generateSimplifiedSummary(summary: string, focus: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("Summary");
        return await this.generateSummary(summary, focus, openAIRequestDirector);
    }

    public async checkIfBirdAppearanceUnisex(description: string): Promise<boolean> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("Summary");
        const request = openAIRequestDirector.buildGPT3request(description) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(request);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the bird appearance");
        }
        return (chatGPTResponse.choices[0].message.content == "True");
    }

    public async generateColoursFromDescription(description: string, gender: string, bodyParts: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("ColourGenerator");
        const request = openAIRequestDirector.buildColourGeneratorRequest(description, gender, bodyParts) as any;
        console.log(request);
        const chatGPTResponse = await this._openAIClient.chat.completions.create(request);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the colour generation");
        }
        console.log(chatGPTResponse.choices[0].message.content);
        return chatGPTResponse.choices[0].message.content;
    }

    public async generateCustomSummary(summary: string, focus: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("CustomSummaries");
        return await this.generateSummary(summary, focus, openAIRequestDirector);
    }

    public async findDiet(description: string, diets: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("Diet");
        return await this.generateSummary(description, diets, openAIRequestDirector);
    }

    public async generateTraits(description: string, birdName: string, traits: string) {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("TraitGenerator");
        const request = openAIRequestDirector.buildTraitGeneratorRequest(description, birdName, traits) as any;
        console.log(request);
        const chatGPTResponse = await this._openAIClient.chat.completions.create(request);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the colour generation");
        }
        console.log(chatGPTResponse.choices[0].message.content);
        return chatGPTResponse.choices[0].message.content;
    }
}

export default { ChatGPT, OpenAIRequestDirector, OpenAIRequestBuilder };