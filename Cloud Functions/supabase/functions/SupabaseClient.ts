import { SupabaseClient, createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'


export type BirdLabel = {
    Label: string,
    IsSpecific: boolean,
    DefaultBird: string | null
}

export type BlacklistLabel = {
    Label: string
}

export type BirdSpecies = {
    birdId: string;
    birdName: string;
    birdDescription: string;
    birdScientificName: string;
    birdFamily: string;
    birdShapeId: string;
    dietId: string;
    birdImageUrl: string;
    createdAt: string;
    version: string;
    birdSimulationInfo: string[];
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
} 

export default { Supabase };