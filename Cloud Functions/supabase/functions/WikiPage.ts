import { ChatGPT } from "./OpenAIClient.ts";
import { WikiPageRequest } from "./WikiPageRequest.ts";
import { WikiParser } from "./WikiParser.ts";

// Composite object
export class WikiPage {
    protected readonly _wikiPageRequest: WikiPageRequest;
    protected _wikiParser!: WikiParser;

    constructor(pageName: string | URL) {
        this._wikiPageRequest = new WikiPageRequest(pageName);
    }

    protected isParserSetup(): void {
        if(this._wikiParser == undefined) {
            throw new Error("The setupParser method wasn't called");
        }
    }

    public async setupParser(): Promise<void> {
        if(this._wikiParser != undefined) return;
        await this._wikiPageRequest.search();
        this._wikiParser = new WikiParser(await this._wikiPageRequest.fetch());
    }
}

// Extends the wikiPage class with bird wiki page specific functions
export class BirdWikiPage extends WikiPage {
    private _isSummaryAboutBirds: boolean;
    private _hasSummaryBeenChecked: boolean;
    private _isNoHeadingPage: boolean;

    constructor(pageName: string | URL) {
        super(pageName);
        this._isSummaryAboutBirds = false;
        this._hasSummaryBeenChecked = false;
        this._isNoHeadingPage = false;
    }

    public async setupParser(): Promise<void> {
        if(this._wikiParser != undefined) return;
        await this._wikiPageRequest.search();
        this._wikiParser = new WikiParser(await this._wikiPageRequest.fetch());
        this._isNoHeadingPage = this._wikiParser.isNoHeadingPage();
    }

    private async isSummaryAboutBirds(): Promise<boolean> {
        if (this._hasSummaryBeenChecked) return this._isSummaryAboutBirds;
        this.isParserSetup();
        const summary = this._wikiParser.getSummary() as string;
        this._isSummaryAboutBirds = await ChatGPT.instantiate().checkIfSummaryIsAboutBirds(summary);
        this._hasSummaryBeenChecked = true;
        return this._isSummaryAboutBirds;
    }

    public getBirdSummary(): string {
        return this._wikiParser.getSummary();
    }

    public getBirdScientificName(): string {
        return this._wikiParser.getBinomialName();
    }

    public getBirdName(): string {
        return this._wikiParser.getPageTitle();
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
            console.log(this._wikiParser.hasInfoBoxProperty("Family"));
            console.log(this._wikiParser.hasInfoBoxProperty("Species"));

            return false;
        }
        if(!(await this.isSummaryAboutBirds())) {
            // console.log(await this.isSummaryAboutBirds());
            return false;
        }
        return true;
    }



}

export class ReferralWikiPage extends WikiPage {
    private _present_section: string | undefined;
    private _sections: string[];

    constructor(pageName: string, sections: string[]) {
        super(pageName);
        this._sections = sections;
    }
    

    private getReferralSection(): string {
        this.isParserSetup();
        const present_section = this._sections.find(section => {
            return this._wikiParser.hasSection(section);
        });
        if (present_section == undefined) {
            throw new Error("There is no referral section");
        }
        return present_section;
    }

    public isReferralPage(): boolean {
        this.isParserSetup();
        return this._sections.some(section => {
            return this._wikiParser.hasSection(section);
        })
    }

    public getFirstBirdReferralPage(): BirdWikiPage {
        this.isParserSetup();
        this._present_section = this.getReferralSection();
        const links: string[] =  this._wikiParser.getLinksFromSection(this._present_section);
        if (links.length == 0) {
            throw new Error("The referral page section didn't have any links");
        }
        const birdWikiPageUrl: URL = new URL(links[0]);
        return new BirdWikiPage(birdWikiPageUrl);
    }
}

export default { BirdWikiPage, WikiPage, ReferralWikiPage };