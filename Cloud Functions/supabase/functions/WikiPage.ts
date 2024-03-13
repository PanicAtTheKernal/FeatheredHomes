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
    private readonly _descriptionHeading: string;
    private _isSummaryAboutBirds: boolean;
    private _hasSummaryBeenChecked: boolean;
    private _isNoHeadingPage: boolean;
    private readonly _behaviourHeading: string;
    private readonly _breeding: string;

    constructor(pageName: string | URL) {
        super(pageName);
        this._isSummaryAboutBirds = false;
        this._hasSummaryBeenChecked = false;
        this._isNoHeadingPage = false;
        this._descriptionHeading = "Description";
        this._behaviourHeading = "Behaviour";
        this._breeding = "Breeding";
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
        console.log(summary);
        this._isSummaryAboutBirds = await ChatGPT.instantiate().checkIfSummaryIsAboutBirds(summary);
        console.log("ChatGPT returned: " + this._isSummaryAboutBirds);
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

    public async getDescription(): Promise<string> {
        if(this._wikiParser.hasFullSection(this._descriptionHeading)) {
            const description = WikiParser.replaceCitations(this._wikiParser.getFullSection(this._descriptionHeading));
            if (description.length/ChatGPT.TOKEN_SIZE > 700) {
                return await ChatGPT.instantiate().generateCustomSummary(description, "colours and appearance");
            }
            return WikiParser.replaceCitations(this._wikiParser.getFullSection(this._descriptionHeading));
        } else if (this._wikiParser.hasSection(this._descriptionHeading)) {
            return WikiParser.replaceCitations(this._wikiParser.getSection(this._descriptionHeading))
        } else  {
            // No heading page case
            const noHeadingPageContent = WikiParser.replaceCitations(this._wikiParser.getSummary());
            return await ChatGPT.instantiate().generateCustomSummary(noHeadingPageContent, "description");
        }
    }

    public async getBehaviourSection(): Promise<string> {
        if (this._wikiParser.hasFullSection(this._behaviourHeading)) {
            return this._wikiParser.getFullSection(this._behaviourHeading);
        } else if (this._wikiParser.hasFullSection(this._breeding)) {
            return this._wikiParser.getFullSection(this._breeding);
        } else {
            const noHeadingPageContent = WikiParser.replaceCitations(this._wikiParser.getSummary());
            return await ChatGPT.instantiate().generateCustomSummary(noHeadingPageContent, "behaviour, nesting and breeding");
        }
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
            console.log("No family or species");
            return false;
        }
        if(!(await this.isSummaryAboutBirds())) {
            console.log(await this.isSummaryAboutBirds());
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