import { ChatGPT } from "../OpenAIClient.ts";
import { Supabase } from "../SupabaseClient.ts";

export class TraitGenerator {
    private readonly _birdName: string;
    private readonly _description: string;
    private _traits: string[];
    private _birdTraits: Map<string, boolean>;

    constructor(description: string, birdName: string) {
        this._traits = [];
        this._birdTraits = new Map();
        this._birdName = birdName;
        this._description = description;
    }

    private async fetchTraits(): Promise<void> {
        this._traits = await Supabase.instantiate().fetchTraits();
    }

    public async generateTraits(): Promise<void> {
        await this.fetchTraits()
        const traitsString = `${this._traits.join(", ").replace(/[,]$/, "")}`;
        const birdObject = await ChatGPT.instantiate().generateTraits(this._description, this._birdName, traitsString);
        this._birdTraits = new Map(Object.entries(JSON.parse(birdObject)));
    }

    public get birdTraits(): Map<string, boolean> {
        return this._birdTraits;
    }
}

export default {}