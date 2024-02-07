import { ChatGPT } from "../OpenAIClient.ts";
import { BirdShape, GenderImages, Supabase, UnisexImage } from "../SupabaseClient.ts";

export class ImageGenerator {
    private readonly _description: string;
    private readonly _family: string;
    private _images: UnisexImage | GenderImages | undefined;
    private _shapeId: string;
    private _templateJson: object;
    private _templateUrl: string;
    private _unisex: boolean;

    constructor(description: string, family: string) {
        this._description = description;
        this._family = family;
        this._shapeId = "";
        this._unisex = true;
        this._templateJson = {};
        this._templateUrl = "";
    }

    private async fetchTemplate(): Promise<void> {
        this._shapeId = await Supabase.instantiate().fetchShapeFromFamily(this._family);
        const birdShape: BirdShape = await Supabase.instantiate().fetchBirdShape(this._shapeId);
        this._templateJson = birdShape.BirdShapeTemplateJson;
        this._templateUrl = birdShape.BirdShapeTemplateUrl;
    }

    private async isBirdLookUnisex(): Promise<boolean> {
        return await ChatGPT.instantiate().checkIfBirdAppearanceUnisex(this._description);
    }

    private async generateUnisexImage(): Promise<void> {
        
    }

    private async generateGenderImages(): Promise<void> {
        return;
    } 

    private async modifyTemplateImage(): Promise<void> {

    }

    private createHashmapOfColours(): void {
        
    }


    public async generate(): Promise<void> {
        await this.fetchTemplate();
        if (await this.isBirdLookUnisex()) {
            await this.generateUnisexImage();
        } else {
            await this.generateGenderImages();
        }
    }    

    public get shapeId(): string {
        if (this._shapeId == undefined) {
            throw new Error("The image needs to be generated first");
        } 
        return this._shapeId;
    }

    public get images(): UnisexImage | GenderImages {
        if (this._images == undefined) {
            throw new Error("The image needs to be generated first");
        } 
        return this._images;
    }
}

export default { ImageGenerator }