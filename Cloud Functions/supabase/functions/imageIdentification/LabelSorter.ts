import { BirdWikiPage, ReferralWikiPage } from "./../WikiPage.ts";
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
    private _birdReferralSections: string[];

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
        this._birdReferralSections = ["Birds","Species"];
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

    private async sortLabel(label: string): Promise<void> {
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

    private async sortUnknownLabel(label: string): Promise<void> {
        let wikiPage: BirdWikiPage = new BirdWikiPage(label);
        try {
            await wikiPage.setupParser();
            if(!(await wikiPage.isPageAboutBirds())) {
                const referralPage = new ReferralWikiPage(label, this._birdReferralSections);
                await referralPage.setupParser();
                if (!referralPage.isReferralPage()) {
                    throw new Error("Not a bird page");
                } else {
                    wikiPage = referralPage.getFirstBirdReferralPage();
                    // Need to call it again if the referral page return a new bird wiki page
                    await wikiPage.setupParser();
                }
            } 
            if(await wikiPage.isBirdSpecies()) {
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
            }
        } catch (error) {
            console.log(`LabelSorter (${label}): ${error}`);
            // There is no wiki page for it then it gets add to the blacklist
            await Supabase.instantiate().addBlacklistLabel({
                Label: label
            })
            this._blacklistedLabels.push(label);
        }
    }

    public async sort(labels: string[]): Promise<void> {
        this._labels = labels;
        if (!this.isBird()) {
            throw new Error("No bird");
        }
        await this.fetchLabelLists();
        for(let label in this._labels) {
            await this.sortLabel(label.toUpperCase());
        }
        this.sortedLabels.isBird = true;
    }

    public get sortedLabels(): SortedLabels {
        return this._sortedLabels;
    }
}

export default { LabelSorter };