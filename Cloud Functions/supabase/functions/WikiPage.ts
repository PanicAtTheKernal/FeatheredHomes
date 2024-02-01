import { ChatGPT } from "./OpenAIClient.ts";
import { WikiPageRequest } from "./WikiPageRequest.ts";
import { WikiParser } from "./WikiParser.ts";

// Composite object
export class WikiPage {
    protected readonly _wikiPageRequest: WikiPageRequest;
    protected _wikiParser!: WikiParser;

    constructor(pageName: string) {
        this._wikiPageRequest = new WikiPageRequest(pageName);
    }

    protected isParserSetup(): void {
        if(this._wikiParser == undefined) {
            throw new Error("The setupParser method wasn't called");
        }
    }
}

// Extends the wikiPage class with bird wiki page specific functions
export class BirdWikiPage extends WikiPage {
    private _isSummaryAboutBirds;
    private _hasSummaryBeenChecked;

    constructor(pageName: string) {
        super(pageName);
        this._isSummaryAboutBirds = false;
        this._hasSummaryBeenChecked = false;
    }

    private async isSummaryAboutBirds(): Promise<boolean> {
        if (this._hasSummaryBeenChecked) return this._isSummaryAboutBirds;
        this.isParserSetup();
        const summary = this._wikiParser.getSummary() as string;
        this._isSummaryAboutBirds = await ChatGPT.instantiate().checkIfSummaryIsAboutBirds(summary);
        this._hasSummaryBeenChecked = true;
        return this._isSummaryAboutBirds;
    }
    
    public async setupParser(): Promise<void> {
        if(this._wikiParser != undefined) return;
        await this._wikiPageRequest.search();
        this._wikiParser = new WikiParser(await this._wikiPageRequest.fetch());
    }

    public getBirdFamily(): string {
        this.isParserSetup();
        return this._wikiParser.getInfoBoxProperty("Family") as string;
    }

    public getBirdSpecies(): string {
        this.isParserSetup();
        return this._wikiParser.getBinomialName() as string;
    }

    public async getDefaultBirdName(): Promise<string> {
        this.isParserSetup();
        const infoBoxText = this._wikiParser.getInfoBoxImageText();
        return await ChatGPT.instantiate().extractBirdName(infoBoxText);
    }

    public async isBirdFamily(): Promise<boolean> {
        this.isParserSetup();
        if(!this._wikiParser.hasInfoBoxProperty("Family"))  return false;
        if(!(await this.isSummaryAboutBirds())) return false;
        return true;
    }

    public async isBirdSpecies(): Promise<boolean> {
        this.isParserSetup();
        if(!this._wikiParser.hasInfoBoxProperty("Species")) return false;
        if(!(await this.isBirdFamily())) return false;
        return true;
    }

    public async isPageAboutBirds(): Promise<boolean> {
        this.isParserSetup();
        if(!this._wikiParser.hasInfoBoxProperty("Family") && !this._wikiParser.hasInfoBoxProperty("Species")) {
            return false;
        }
        if(!(await this.isSummaryAboutBirds())) {
            return false;
        }
        return true;
    }
}

export default { BirdWikiPage, WikiPage };