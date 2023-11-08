import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

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

    constructor (adminClient: SupabaseClient) {
        this._adminClient = adminClient;
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

    public async getAllDiets(): Promise<Array<string>> {
        const { data, error } = await this._adminClient.from("Diet")
        .select("DietName")

        if (error != null) {
            return [];
        }

        const dietNames = data.map((dietName) => dietName["DietName"]);
        return dietNames;
    }

    public async systemMessagePrep(messageName: string, values?: string) {

    }

    public async askGPT(systemMessage: string, content: string, model: string, imageUrl?: URL) {
    }
}