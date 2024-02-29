import { BirdSpecies, Supabase } from "../SupabaseClient.ts";
import WikiPage, { BirdWikiPage } from "../WikiPage.ts";
import { crypto } from "https://deno.land/std@0.202.0/crypto/crypto.ts";
import { ChatGPT } from "../OpenAIClient.ts";
import { ImageGenerator } from "./ImageGenerator.ts";
import { DietGenerator } from "./DietGenerator.ts";
import { TraitGenerator } from "./TraitGenerator.ts";

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
            birdUnisex: true,
            birdColourMap: { image: "" },
            birdNest: "",
            birdSound: "",
            isPredator: false,
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
        const description = await this._wikiPage.getDescription();
        const familyName = this._wikiPage.getBirdFamily().toUpperCase();
        const birdName = this._wikiPage.getBirdName();
        this._imageGenerator = new ImageGenerator(description, familyName, birdName);
        await this._imageGenerator.generate();
        this._generatedBird.birdUnisex = this._imageGenerator.unisex;
        this._generatedBird.birdShapeId = this._imageGenerator.shapeId;
        this._generatedBird.birdImages = this._imageGenerator.images;
        this._generatedBird.birdColourMap = this._imageGenerator.colourMaps;
    }

    private generateScientificName(): void {
        this._generatedBird.birdScientificName = this._wikiPage.getBirdScientificName().toUpperCase();
    }

    private async generateTraits(): Promise<void> {
        const description = await this._wikiPage.getBehaviourSection();
        const birdName = this._wikiPage.getBirdName();
        const traitGenerator = new TraitGenerator(description, birdName);
        await traitGenerator.generateTraits()
        this._generatedBird.birdSimulationInfo = Object.fromEntries(traitGenerator.birdTraits);
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
        const description = await this._wikiPage.getBehaviourSection();
        const dietGenerator: DietGenerator = new DietGenerator(description);
        this._generatedBird.dietId = await dietGenerator.generate();
    }

    private async generateSound(): Promise<void> {
        const sounds = await Supabase.instantiate().fetchSounds();
        const soundsString = `${sounds.join(", ").replace(/[,]$/, "")}`;
        const soundId = await ChatGPT.instantiate().generateSound(this._wikiPage.getBirdName(), soundsString);
        this._generatedBird.birdSound = await Supabase.instantiate().fetchSoundId(soundId);
    }
    private async isPredator(): Promise<void> {
        const description = await this._wikiPage.getBehaviourSection();
        const isPredator = await ChatGPT.instantiate().checkIfBirdIsPredator(description);
        this._generatedBird.isPredator = isPredator;
    }

    private async generateNest(): Promise<void> {
        const nests = await Supabase.instantiate().fetchNests();
        const description = await this._wikiPage.getBehaviourSection();
        const shortenDescription = await ChatGPT.instantiate().generateCustomSummary(description, "breeding, nesting and behaviour");
        const nestsString = `${nests.join(", ").replace(/[,]$/, "")}`;
        const nest = await ChatGPT.instantiate().generateNest(shortenDescription.concat(` BirdName: ${this._wikiPage.getBirdName}`), nestsString);
        this._generatedBird.birdNest = await Supabase.instantiate().fetchNestId(nest);
    }

    private setVersion(): void {
        this._generatedBird.version = this._version;
    }

    public async setupGenerator(): Promise<void> {
        await this._wikiPage.setupParser();
    }

    public async generate(): Promise<void> {
        this.generateId();
        this.generateName();
        this.generateFamilyName();
        await this.generateDescription();
        await this.generateImage();
        this.generateScientificName();
        await this.generateTraits();
        this.generateDate();
        await this.generateDiet();
        await this.generateSound();
        await this.isPredator();
        await this.generateNest();
        this.setVersion();
        await Supabase.instantiate().uploadNewBird(this._generatedBird);
    }

    public get generatedBird(): BirdSpecies {
        return this._generatedBird;
    }
}

export default { BirdAssetGenerator }