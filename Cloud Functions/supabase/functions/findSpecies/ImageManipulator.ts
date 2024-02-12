import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';
import { ColourMap } from './ColourMap.ts';


export class ImageManipulator {
    private readonly _templateImageUrl: string;
    private readonly _colourMap: ColourMap; 
    private _templateImage!: Image;  
    private _finalImage!: Image;  

    constructor(templateImageUrl: string, colourMap: ColourMap) {
        this._templateImageUrl = templateImageUrl;
        this._colourMap = colourMap;
    }

    private async fetchImage(): Promise<void> {
        const imageTemplateBuffer = await fetch(this._templateImageUrl).then(result => result.arrayBuffer()) as Buffer;
        this._templateImage = await Image.decode(imageTemplateBuffer);
        this._finalImage = new Image(this._templateImage.width, this._templateImage.height);
    }

    public async modifyImage(): Promise<Uint8Array> {
        await this.fetchImage();
        for(let x = 1; x <= this._templateImage.width; x++) {
            for(let y = 1; y <= this._templateImage.height; y++) {
                const colourValue = this._templateImage.getPixelAt(x,y);
                let newPixelColourHex = this._colourMap.getValue(colourValue);
                if(newPixelColourHex == undefined) {
                    newPixelColourHex = colourValue;
                }
                this._finalImage.setPixelAt(x, y, newPixelColourHex);
            }
        }
        return await this._finalImage.encode();
    }
}

export default { ImageManipulator }