import { ChatGPT } from "../OpenAIClient.ts";
import { BirdShape, GenderImages, Supabase, UnisexImage } from "../SupabaseClient.ts";
import { ColourMap } from "./ColourMap.ts";
import { ImageManipulator } from "./ImageManipulator.ts";

export class ImageGenerator {
    private readonly _description: string;
    private readonly _family: string;
    private readonly _birdName: string;
    private _images: UnisexImage | GenderImages | undefined;
    private _colourMaps: UnisexImage | GenderImages | object;
    private _shapeId: string;
    private _shapeName: string;
    private _templateJson: object;
    private _colourJson: object;
    private _templateUrl: string;
    private _unisex: boolean;

    constructor(description: string, family: string, birdName: string) {
        this._description = description;
        this._family = family;
        this._shapeId = "";
        this._shapeName = "";
        this._unisex = true;
        this._templateJson = {};
        this._templateUrl = "";
        this._colourJson = {};
        this._birdName = birdName;
        this._colourMaps = {};
    }

    private async fetchTemplate(): Promise<void> {
        this._shapeId = await Supabase.instantiate().fetchShapeFromFamily(this._family);
        const birdShape: BirdShape = await Supabase.instantiate().fetchBirdShape(this._shapeId);
        this._templateJson = birdShape.BirdShapeTemplateJson;
        this._templateUrl = birdShape.BirdShapeTemplateUrl;
        this._shapeName = birdShape.BirdShapeName;
    }

    private async isBirdLookUnisex(): Promise<boolean> {
        this._unisex = await ChatGPT.instantiate().checkIfBirdAppearanceUnisex(this._description);
        return this._unisex;
    }

    private async generateUnisexImage(): Promise<void> {
        const fileName = this._birdName.replaceAll(" ", "-").toLowerCase();
        this._images = {
            image: await this.generateImageAndUpload("the", fileName)
        };
    }

    private async generateImageAndUpload(gender: string, fileName: string): Promise<string> {
        const templateMap = new Map(Object.entries(this._templateJson));
        const colours = await this.generateListOfColours(gender);
        console.log(templateMap);
        const birdColourMap: ColourMap = new ColourMap(templateMap, colours);
        birdColourMap.createMap();
        this.addColourMap(gender, birdColourMap);
        const imageManipulator: ImageManipulator = new ImageManipulator(this._templateUrl, birdColourMap);
        const birdImage = await imageManipulator.modifyImage();
        return await Supabase.instantiate().uploadBirdImage(this._shapeName, fileName, birdImage);
    }

    private addColourMap(gender: string, colourMap: ColourMap): void {
        switch(gender) {
            case "the":
                // @ts-ignore: Adding property
                this._colourMaps.image = Object.fromEntries(colourMap.colourMap);
                break;
            case "a male":
                // @ts-ignore: Adding property
                this._colourMaps.male = Object.fromEntries(colourMap.colourMap);
                break;
            case "a female":
                // @ts-ignore: Adding property
                this._colourMaps.female = Object.fromEntries(colourMap.colourMap);
                break;
        }
    }

    private generateBodyPartNames(): string {
        let names = "";
        Object.entries(this._templateJson).forEach((entry) => {
            names += `${entry[0]},`;
        });
        return names.replace(/[,]$/, "");
    }

    private async generateListOfColours(gender: string): Promise<Map<string, string>> {
        const colours = await ChatGPT.instantiate().generateColoursFromDescription(this._description, gender, this.generateBodyPartNames());
        return new Map(Object.entries(JSON.parse(colours)));
    }

    private async generateGenderImages(): Promise<void> {
        const maleFileName = this._birdName.replaceAll(" ", "-").toLowerCase().concat("-male");
        const femaleFileName = this._birdName.replaceAll(" ", "-").toLowerCase().concat("-female");
        this._images = {
            male: await this.generateImageAndUpload("a male", maleFileName),
            female: await this.generateImageAndUpload("a female", femaleFileName)
        }
    } 

    public async generate(): Promise<void> {
        await this.fetchTemplate();
        console.log(this.generateBodyPartNames())
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

    public get unisex(): boolean {
        if (this._shapeId == undefined) {
            throw new Error("The image needs to be generated first");
        } 
        return this._unisex;
    }

    public get colourMaps(): UnisexImage | GenderImages {
        if (Object.keys(this._colourMaps).length == 0) {
            throw new Error();
        }
        // @ts-ignore: The if statement handles the edge case of the empty object
        return this._colourMaps;
    }
}

export default { ImageGenerator }