import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'


export type BirdLabel = {
    Label: string,
    IsSpecific: boolean,
    DefaultBird: string | null
}

export type BlacklistLabel = {
    Label: string
}

export type UnisexImage = {
    image: string
}

export type GenderImages = {
    male: string,
    female: string
}

export type BirdShape = {
    BirdShapeName: string;
    BirdShapeTemplateUrl: string;
    BirdShapeTemplateJson: object;
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
    birdSimulationInfo: string[];
    birdUnisex: boolean;
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
    private readonly _birdAssetBucket = "BirdAssets";

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