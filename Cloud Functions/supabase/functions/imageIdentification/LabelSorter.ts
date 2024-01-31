import { BirdWikiPage } from "./../WikiPage.ts";
import { Supabase } from "./../SupabaseClient.ts";

export type SortedLabels = {
    isBird: boolean,
    birdSpeciesLabels: string[],
    birdFamilyLabels: string[],
}

export class LabelSorter {
    private _labels: string[];
    private _birdFamilyLabels: Map<string, string>;
    private _birdSpeciesLabels: string[];
    private _blacklistedLabels: string[];
    private _sortedLabels: SortedLabels;

    constructor() {
        this._labels = [];
        this._birdFamilyLabels = new Map();
        this._birdSpeciesLabels = [];
        this._blacklistedLabels = [];
        this._sortedLabels = {
            isBird: false,
            birdFamilyLabels: [],
            birdSpeciesLabels: [],
        };
    }
    
    private async fetchLabelLists() {
        const supabaseClient = Supabase.instantiate();
        this._birdFamilyLabels = await supabaseClient.fetchBirdFamilyLabels();
        this._birdSpeciesLabels = await supabaseClient.fetchBirdSpeciesLabels();
        this._blacklistedLabels = await supabaseClient.fetchBlacklistedLabels();
    }

    private isLabelBlacklisted(label: string): boolean {
        return this._blacklistedLabels.includes(label);
    }

    private isLabelASpecies(label: string): boolean {
        return this._birdSpeciesLabels.includes(label);
    }

    private isLabelAFamily(label: string): boolean {
        const familyNames: string[] = Array.from(this._birdFamilyLabels.keys());
        return familyNames.includes(label);
    }

    private isBird(): boolean {
        const birdLabel = "Bird";
        return this._labels.includes(birdLabel);
    }

    private async sortLabel(label: string) {
        if (this.isLabelBlacklisted(label)) {
            return;
        }
        if (this.isLabelAFamily(label)) {
            this._sortedLabels.birdFamilyLabels.push(label);
        }
        else if (this.isLabelASpecies(label)) {
            this._sortedLabels.birdSpeciesLabels.push(label);
        }
        else {
            await this.sortUnknownLabel(label);
            await this.sortLabel(label);
        }
    }

    private async sortUnknownLabel(label: string) {
        const wikiPage: BirdWikiPage = new BirdWikiPage(label);
        await wikiPage.setupParser();
        if(!(await wikiPage.isPageAboutBirds())) {
            await Supabase.instantiate().addBlacklistLabel({
                Label: label
            })
            this._blacklistedLabels.push(label);
        } else if(await wikiPage.isBirdSpecies()) {
            await Supabase.instantiate().addBirdLabel({
                Label: label,
                IsSpecific: true,
                DefaultBird: null
            })
            this._birdSpeciesLabels.push(label);
        } else if(await wikiPage.isBirdFamily()) {
            const defaultBirdName = await wikiPage.getDefaultBirdName();
            await Supabase.instantiate().addBirdLabel({
                Label: label,
                IsSpecific: false,
                DefaultBird: defaultBirdName
            })
            this._birdFamilyLabels.set(label, defaultBirdName);
        } else {
            // This is the case if the bird wiki page is missing important information that make it unviable for the bird asset generator
            await Supabase.instantiate().addBlacklistLabel({
                Label: label
            })
            this._blacklistedLabels.push(label);
        }
    }

    public async sort(labels: string[]) {
        this._labels = labels;
        if (!this.isBird()) {
            this._sortedLabels.isBird = false;
            return;
        }
        await this.fetchLabelLists();
        for(let i=0; i<this._labels.length; i++) {
            await this.sortLabel(this._labels[i]);
        }
        this.sortedLabels.isBird = true;
    }

    public get sortedLabels(): SortedLabels {
        return this._sortedLabels;
    }
}

export default { LabelSorter };