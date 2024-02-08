import OpenAI from 'https://deno.land/x/openai@v4.16.1/mod.ts';
import { Supabase } from './SupabaseClient.ts';

export enum GPTModels {
    gpt3="gpt-3.5-turbo-1106",
    gpt4Vision="gpt-4-vision-preview"
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

    public replaceSystemMsgPlaceholder(replacementValues: string[] | string): void {
        if (this._request.messages[0].role != "system") {
            throw new Error("System message not set");
        }

        const replacementValue = "<>";
        switch (typeof replacementValues) {
            case "string": {
                this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replace(replacementValue, replacementValues);
                break;
            }
            case "object": {
                if ((replacementValues instanceof Array)) {
                    if (replacementValues.length == 0) throw new Error("Value length is 0");

                    const list: string = replacementValues
                        .map((replacementValues) => replacementValues.replace(/^/, "- "))
                        .join("\n");
            
                    // Replacement 
                    this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replace(replacementValue, list);
                    break;
                }

                const json = JSON.stringify(replacementValues);
                const removedValues = json.replaceAll(/\[(?:[0-9]+,?)+\]/g, " ");
                this._request.messages[0].content[0].text = this._request.messages[0].content[0].text.replace(replacementValue, removedValues);
        
                break;
            }
            default:
                throw Error("Unsupported type");
        }
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

    public async setSystemMessage(systemMessageName: string, replacementValues?: string | string[]) {
        const message = await Supabase.instantiate().fetchSystemMessage(systemMessageName);
        this._builder.addSystemMessage(message); 
        if (replacementValues != undefined) {
            this._builder.replaceSystemMsgPlaceholder(replacementValues);
        }
    }

    public buildGPT3request(content: string): OpenAIRequest {
        this._builder.addContent(content);
        this._builder.setGPTModel(GPTModels.gpt3);
        return this._builder.getRequest();
    }

    public buildSummaryRequest(summary: string, focus: string): OpenAIRequest {
        this._builder.addContent(summary);
        this._builder.replaceSystemMsgPlaceholder(focus);
        this._builder.setGPTModel(GPTModels.gpt3);
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
        const nameExtractionRequest = openAIRequestDirector.buildGPT3request(text) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(nameExtractionRequest);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the bird name extraction");
        }
        return chatGPTResponse.choices[0].message.content;
    }

    public async generateSimplifiedSummary(summary: string, focus: string): Promise<string> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("Summary");
        const nameExtractionRequest = openAIRequestDirector.buildSummaryRequest(summary, focus) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(nameExtractionRequest);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the simplified bird summary");
        }
        return chatGPTResponse.choices[0].message.content;
    }

    public async checkIfBirdAppearanceUnisex(description: string): Promise<boolean> {
        const openAIRequestDirector = new OpenAIRequestDirector();
        await openAIRequestDirector.setSystemMessage("Summary");
        const nameExtractionRequest = openAIRequestDirector.buildGPT3request(description) as any;
        const chatGPTResponse = await this._openAIClient.chat.completions.create(nameExtractionRequest);
        if (chatGPTResponse.choices[0].message.content == null) {
            throw new Error("ChatGPT: There was an error with chatGPT and the bird appearance");
        }
        return (chatGPTResponse.choices[0].message.content == "True");
    }
}

export default { ChatGPT, OpenAIRequestDirector, OpenAIRequestBuilder };