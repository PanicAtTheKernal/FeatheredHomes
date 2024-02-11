import { ChatGPT } from "../OpenAIClient.ts";
import { Supabase } from "../SupabaseClient.ts";

export class DietGenerator {
    private readonly _description: string;
    private _diets: string[];
    private _diet: string;
    private _dietId: string;

    constructor(description:string) {
        this._description = description;
        this._diets = [];
        this._diet = "";
        this._dietId = "";
    }

    private async getAllDiets(): Promise<string[]> {
        this._diets = await Supabase.instantiate().fetchDiets();
        return this._diets;
    }

    public async generate(): Promise<void> {
        await this.getAllDiets();
        const shortenDescription = await ChatGPT.instantiate().generateCustomSummary(this._description, "diet");
        const dietString = `${this._diets.join(", ").replace(/[,]$/, "")}`;
        this._diet = await ChatGPT.instantiate().findDiet(shortenDescription, dietString);
        this._dietId = await Supabase.instantiate().fetchDietId(this._diet);
    }

    public get dietId(): string {
        return this._dietId;
    }
}

export default { DietGenerator }