import { BirdShape, GenderImages, Supabase, UnisexImage } from "../SupabaseClient.ts";
import { ColourMap } from "../findSpecies/ColourMap.ts";
import { ImageManipulator } from "../findSpecies/ImageManipulator.ts";

export class ImageGeneratorLite {
    private readonly _fileName: string;
    private _images: UnisexImage | GenderImages | undefined;
    private _colourMaps: UnisexImage | GenderImages | object;
    private _shapeId: string;
    private _shapeName: string;
    private _templateJson: object;
    private _colourJson: object;
    private _templateUrl: string;
    private _coloursMap: object;

    constructor(coloursMap: object, shapeId: string, fileName: string) {
        this._shapeId = shapeId;
        this._shapeName = "";
        this._templateJson = {};
        this._templateUrl = "";
        this._colourJson = {};
        this._fileName = fileName;
        this._colourMaps = {};
        this._coloursMap = coloursMap;
    }

    private async fetchTemplate(): Promise<void> {
        const birdShape: BirdShape = await Supabase.instantiate().fetchBirdShape(this._shapeId);
        this._templateJson = birdShape.BirdShapeTemplateJson;
        this._templateUrl = birdShape.BirdShapeTemplateUrl;
        this._shapeName = birdShape.BirdShapeName;
    }

    public async generateImageAndUpload(): Promise<string> {
        await this.fetchTemplate();
        const templateMap = new Map(Object.entries(this._templateJson));
        const colours = new Map(Object.entries(this._coloursMap));
        const birdColourMap: ColourMap = new ColourMap(templateMap, colours);
        birdColourMap.createMap();
        // this.addColourMap(birdColourMap);
        const imageManipulator: ImageManipulator = new ImageManipulator(this._templateUrl, birdColourMap);
        const birdImage = await imageManipulator.modifyImage();
        return await Supabase.instantiate().uploadBirdImage(this._shapeName, this._fileName, birdImage);
    }

    // private addColourMap(gender: string, colourMap: ColourMap): void {
    //     switch(gender) {
    //         case "the":
    //             // @ts-ignore: Adding property
    //             this._colourMaps.image = Object.fromEntries(colourMap.colourMap);
    //             break;
    //         case "a male":
    //             // @ts-ignore: Adding property
    //             this._colourMaps.male = Object.fromEntries(colourMap.colourMap);
    //             break;
    //         case "a female":
    //             // @ts-ignore: Adding property
    //             this._colourMaps.female = Object.fromEntries(colourMap.colourMap);
    //             break;
    //     }
    // }

    public get shapeId(): string {
        if (this._shapeId == "") {
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

    public get colourMaps(): UnisexImage | GenderImages {
        if (Object.keys(this._colourMaps).length == 0) {
            throw new Error();
        }
        // @ts-ignore: The if statement handles the edge case of the empty object
        return this._colourMaps;
    }
}

export default { ImageGeneratorLite }