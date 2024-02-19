import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';

export class ColourMap {
    private readonly _colourMap: Map<number, number>;
    private readonly _colourHexMap: Map<string, string>;
    private readonly _template: Map<string, string>;
    private readonly _colours: Map<string, string>;
    private readonly _alphaValue: number;


    constructor (template: Map<string, string>, colours: Map<string, string>) {
        this._colourMap = new Map();
        this._colourHexMap = new Map();
        this._template = template;
        this._colours = colours;
        this._alphaValue = 255;
    }

    private convertHexToRGB(hexCode: string): number[] {
        const hexCodes = hexCode.replace("#", "").match(/[0-9A-Fa-f]{1,2}/g);
        if (hexCodes == null || hexCodes.length != 3) {
            throw Error(`Fail to parse invalid hexcode ${hexCode}`);
        }
        return hexCodes.map((hexCode: string) => {
            return parseInt(hexCode, 16);
        });
    }

    public createMap(): void {
        this._template.forEach((templateHex, birdPart) => {
            const colourHex: string | undefined = this._colours.get(birdPart);
            if(colourHex == undefined){
                throw new Error(`Missing value: ${birdPart}`);
            }
            const colourRGB = this.convertHexToRGB(colourHex);
            console.log(colourRGB);
            const coloursHash = Image.rgbaToColor(colourRGB[0], colourRGB[1], colourRGB[2], this._alphaValue);
            const templateRGB = this.convertHexToRGB(templateHex);
            const templateHash = Image.rgbaToColor(templateRGB[0], templateRGB[1], templateRGB[2], this._alphaValue);
            this._colourHexMap.set(templateHex, colourHex);
            this._colourMap.set(templateHash, coloursHash);
        })
        console.log(this._colourMap);
    }

    public getValue(colourNumber: number): number | undefined {
        return this._colourMap.get(colourNumber);
    }

    public get colourMap(): Map<string, string> {
        return this._colourHexMap;
    }
}

export default { ColourMap };