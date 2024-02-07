import { BirdSpecies } from "../SupabaseClient.ts";
import { BirdWikiPage } from "../WikiPage.ts";
import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { ChatGPT } from "../OpenAIClient.ts";
import { ImageGenerator } from "./ImageGenerator.ts";

export class BirdAssetGenerator {
    private readonly _birdName: string;
    private readonly _version: string;
    private readonly _wikiPage: BirdWikiPage;
    private readonly _generatedBird: BirdSpecies;
    private _imageGenerator!: ImageGenerator;

    constructor (birdName: string) {
        this._birdName = birdName;
        this._version = Deno.env.get("VERSION") as string;
        this._generatedBird = {
            birdId: "", 
            birdName: "",
            birdFamily: "",
            birdDescription: "",
            birdImages: { image: "" },
            birdScientificName: "",
            birdShapeId: "",
            birdSimulationInfo: [],
            createdAt: "",
            dietId: "",
            version: "",
            birdUnisex: true
        };
        // Label is in upper case but the request will only work if it's lowercase
        this._wikiPage = new BirdWikiPage(birdName.toLowerCase());
    }

    private generateId(): void {
        this._generatedBird.birdId = crypto.randomUUID();
    }

    private generateName(): void {
        //Use the title from the wiki page as the bird name, which reduce variance in the label
        this._generatedBird.birdName = this._wikiPage.getBirdName().toUpperCase();
    }

    private generateFamilyName(): void {
        this._generatedBird.birdFamily = this._wikiPage.getBirdFamily().toUpperCase();
    }

    private async generateDescription(): Promise<void> {
        const wikiSummary = this._wikiPage.getBirdSummary();
        const birdName = this._wikiPage.getBirdName().toLowerCase()
        const improvedSummary = await ChatGPT.instantiate().generateSimplifiedSummary(wikiSummary, birdName);
        this._generatedBird.birdDescription = improvedSummary;
    }

    private async generateImage(): Promise<void> {
        const description = this._wikiPage.getDescription();
        const familyName = this._wikiPage.getBirdFamily().toUpperCase();
        this._imageGenerator = new ImageGenerator(description, familyName);
        await this._imageGenerator.generate();
    }

    private generateScientificName(): void {
        this._generatedBird.birdScientificName = this._wikiPage.getBirdScientificName().toUpperCase();
    }

    private generateShapeId(): void {
        // Get it from the image generator class
    }

    private async generateTraits(): Promise<void> {

    } 

    private generateDate(): void {
        const date = new Date();
        this._generatedBird.createdAt += `${date.getFullYear()}`;
        // Have to offset month by 1 since data.getMonth returns the values between 0-11 and not 1-12
        this._generatedBird.createdAt += `-${date.getMonth()+1}`;
        this._generatedBird.createdAt += `-${date.getDate()}`;
        this._generatedBird.createdAt += ` ${date.getHours()}`;
        this._generatedBird.createdAt += `:${date.getMinutes()}`;
        this._generatedBird.createdAt += `:${date.getSeconds()}`;
        this._generatedBird.createdAt += `.${date.getMilliseconds()}`;
    }

    private async generateDiet(): Promise<void> {

    }

    private setVersion(): void {
        this._generatedBird.version = this._version;
    }

    public async setupGenerator(): Promise<void> {
        await this._wikiPage.setupParser();
    }

    public async generate(): Promise<void> {
        // TODO add logic for single heading wiki pages
        this.generateId();
        this.generateName();
        this.generateFamilyName();
        // await this.generateDescription();
        await this.generateImage();
        this.generateScientificName();
        this.generateShapeId();
        await this.generateTraits();
        this.generateDate();
        await this.generateDiet();
        this.setVersion();
    }

    public get generatedBird(): BirdSpecies {
        return this._generatedBird;
    }
}

export default { BirdAssetGenerator }