import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { ColourMap } from './findSpecies/ColourMap.ts';


export type BirdLabel = {
    Label: string,
    IsSpecific: boolean,
    DefaultBird: string | null
}

export type BlacklistLabel = {
    Label: string
}

export type UnisexImage = {
    image: string | ColourMap
}

export type GenderImages = {
    male: string | ColourMap,
    female: string | ColourMap
}

export type BirdShape = {
    BirdShapeName: string;
    BirdShapeTemplateUrl: string;
    BirdShapeTemplateJson: object;
}

export type Log = {
    Function: string;
    Request: object;
    IsError: boolean;
    Error: object | null;
}

export type BirdSpecies = {
    birdId: string;
    birdName: string;
    birdDescription: string;
    birdScientificName: string;
    birdFamily: string;
    birdShapeId: string;
    dietId: string;
    birdImages: UnisexImage | GenderImages;
    createdAt: string;
    version: string;
    birdSimulationInfo: object;
    birdUnisex: boolean;
    birdColourMap: object;
    birdSound: string;
    birdNest: string;
    isPredator: boolean;
}


type NewLabel = {
    table: string,
    label: BirdLabel | BlacklistLabel
}

export class Supabase {
    private static instance: Supabase;
    private readonly _supabaseServiceRoleKey: string;
    private readonly _supabaseUrl: string; 
    private readonly _supabaseAdminClient: SupabaseClient
    private readonly _blacklistTable = "BlacklistedLabels";
    private readonly _birdLabelsTable = "BirdLabels";
    private readonly _systemMessageTable = "SystemMessages";
    private readonly _birdSpeciesTable = "BirdSpecies";
    private readonly _familyToShapeTable = "FamilyToShape";
    private readonly _birdShapeTable = "BirdShape";
    private readonly _dietTable = "Diet";
    private readonly _traitTable = "Traits";
    private readonly _birdAssetBucket = "BirdAssets";
    private readonly _logTable = "Log";
    private readonly _soundTable = "Sound";
    private readonly _nestTable = "Nest";

    private constructor() {
        this._supabaseServiceRoleKey = Deno.env.get("SERVICE_ROLE_KEY") as string;
        this._supabaseUrl = Deno.env.get("HOST_URL") as string;
        this._supabaseAdminClient = createClient(
            this._supabaseUrl,
            this._supabaseServiceRoleKey
        );
    }

    private async addLabel(newLabel: NewLabel): Promise<void> {
        const response = await this._supabaseAdminClient.from(newLabel.table).insert(newLabel.label);
        if(response.error) {
            throw new Error(`Inserting a new label resulted in this error "${response.error.message}"`);
        }
    }

    public static instantiate(): Supabase {
        if (this.instance == undefined) {
            this.instance = new Supabase();
        }
        return this.instance;
    }

    public async fetchSystemMessage(systemMessageName: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._systemMessageTable)
            .select("SystemMessageContent")
            .eq("SystemMessageName", systemMessageName);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        if (data.length == 0) {
            const errorMessage = `Supabase: System message ${systemMessageName} was not found`;
            throw Error(errorMessage);
        }
        return data[0].SystemMessageContent;
    }

    public async fetchBlacklistedLabels(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._blacklistTable)
            .select("Label");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map((labelObj) => {
            return labelObj.Label;
        });
    }

    public async fetchBirdFamilyLabels(): Promise<Map<string, string>> {
        const { data, error } = await this._supabaseAdminClient.from(this._birdLabelsTable)
            .select("Label, DefaultBird")
            .eq("IsSpecific", "FALSE");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        const birdFamilyLabels: Map<string, string> = new Map();
        data.forEach((labelObj) => {
            birdFamilyLabels.set(labelObj.Label, labelObj.DefaultBird) ;
        })
        return birdFamilyLabels;
    }

    public async fetchBirdSpeciesLabels(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._birdLabelsTable)
            .select("Label")
            .eq("IsSpecific", "TRUE");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map((labelObj) => {
            return labelObj.Label;
        });
    }

    public async fetchBirdSpecies(birdName: string): Promise<BirdSpecies | null> {
        const { data, error } = await this._supabaseAdminClient.from(this._birdSpeciesTable)
            .select()
            .like("birdName", `%${birdName}%`);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        console.log(data);
        return (data.length != 0) ? data[0] : null;
    }

    public async fetchDefaultBirdName(label: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._birdLabelsTable)
            .select("DefaultBird")
            .eq("Label", label);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data[0].DefaultBird;
    }

    public async fetchShapeFromFamily(familyName: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._familyToShapeTable)
            .select("Shape")
            .limit(1)
            .eq("Family", familyName);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        if (data.length == 0) {
            throw Error("No template found");
        }
        return data[0].Shape as string;
    }   

    public async fetchBirdShape(shapeId: string): Promise<BirdShape> {
        const { data, error } = await this._supabaseAdminClient.from(this._birdShapeTable)
            .select("BirdShapeName, BirdShapeTemplateUrl, BirdShapeTemplateJson")
            .eq("BirdShapeId", shapeId);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data[0] as BirdShape;
    }

    public async fetchDiets(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._dietTable)
            .select("DietName");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map(entry => entry.DietName);
    }

    public async fetchDietId(diet: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._dietTable)
            .select("DietId")
            .eq("DietName", diet);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data[0].DietId as string;
    }

    public async fetchTraits(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._traitTable)
        .select("traitName");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map(entry => entry.traitName); 
    }

    public async fetchSounds(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._soundTable)
        .select("Name");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map(entry => entry.Name); 
    }

    public async fetchSoundId(sound: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._soundTable)
            .select("Id")
            .eq("Name", sound);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data[0].Id as string;
    }

    public async fetchNests(): Promise<string[]> {
        const { data, error } = await this._supabaseAdminClient.from(this._nestTable)
        .select("Type");
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data.map(entry => entry.Type); 
    }

    public async fetchNestId(nest: string): Promise<string> {
        const { data, error } = await this._supabaseAdminClient.from(this._nestTable)
            .select("Id")
            .eq("Type", nest);
        if (error != null) {
            throw new Error(`Supabase: ${error.message}`);
        }
        return data[0].Id as string;
    }

    public async addBlacklistLabel(label: BlacklistLabel): Promise<void> {
        await this.addLabel({
            table: this._blacklistTable,
            label: label
        })
    }

    public async addBirdLabel(label: BirdLabel): Promise<void> {
        await this.addLabel({
            table: this._birdLabelsTable,
            label: label
        })
    }

    public async uploadBirdImage(birdShape: string, birdName: string, image: Uint8Array): Promise<string> {
        await this._supabaseAdminClient.storage.from(this._birdAssetBucket)
            .upload(`${birdShape}/${birdName}.png`, image, {
                contentType: 'image/png'
            })
        const { data } = await this._supabaseAdminClient.storage.from(this._birdAssetBucket)
            .getPublicUrl(`${birdShape}/${birdName}.png`)
        return data.publicUrl;
    }

    public async uploadNewBird(bird: BirdSpecies): Promise<void> {
        const response = await this._supabaseAdminClient.from(this._birdSpeciesTable).insert(bird);
        if(response.error) {
            throw new Error(`Inserting a new label resulted in this error "${response.error.message}"`);
        }
    }

    public async uploadLog(endpoint_name: string, request: object, error?: string): Promise<void> {
        const log: Log = {
            Function: endpoint_name,
            Request: request,
            IsError: (error != undefined),
            Error: (error != undefined) ? {error: error} : null
        }
        const response = await this._supabaseAdminClient.from(this._logTable).insert(log);
        if(response.error) {
            console.log(`Inserting a new log resulted in this error "${response.error.message}"`);
        }
    }

    public async updateDatabase() {
        const list = await this.fetchBirdFamilyLabels();
        const labels = Array.from(list.keys());
        for (const label of labels) {
            console.log(label)
            // console.log(label.toUpperCase());
            const { error } = await this._supabaseAdminClient.from(this._birdLabelsTable)
                .update({ Label: label.toUpperCase(), DefaultBird: list.get(label)?.toUpperCase() })
                .eq('Label', label);
        }
    }
} 

export default { Supabase };