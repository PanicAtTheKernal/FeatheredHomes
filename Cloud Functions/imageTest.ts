import Jimp from "npm:jimp";

/**
 * Tasks:
 * - Read image
 * - Create Hashmap of colour
 * - Create new image with the same size of the template
 * - Loop through the new image and loop through
 */

const alphaValue: number = 255;

async function createHashMapsOfColours(): Promise<Map<number, number>> {
    const testColourFile = await Deno.readTextFile("testColour.json");
    const templateFile = await Deno.readTextFile("template.json");
    const testColour: Map<string, number[]> = new Map(Object.entries(JSON.parse(testColourFile.toString())));
    const template: Map<string, number[]> = new Map(Object.entries(JSON.parse(templateFile.toString())));
    const colourHashMap: Map<number, number> = new Map();

    template.forEach((templateValue, birdPart) => {
        const testColourValue: number[] | undefined = testColour.get(birdPart);

        if(testColourValue == undefined){
            throw new Error(`Missing value: ${birdPart}`);
        }

        const testColourHash = Jimp.rgbaToInt(testColourValue[0], testColourValue[1], testColourValue[2], alphaValue);
        const templateColourHash = Jimp.rgbaToInt(templateValue[0], templateValue[1], templateValue[2], alphaValue);

        colourHashMap.set(templateColourHash, testColourHash);
    })

    console.log(colourHashMap);
    return colourHashMap;
}

async function main():Promise<void> {
    const colourHashMap: Map<number, number> = await createHashMapsOfColours();
    try {
        const imageTemplate: Jimp = await Jimp.read("testImage.png");
        const finalImage: Jimp = new Jimp(imageTemplate.bitmap.width, imageTemplate.bitmap.height);

        imageTemplate.scan(0,0, imageTemplate.bitmap.width, imageTemplate.bitmap.height, (x, y, idx) => {
            const pixelColourHex:number = Jimp.rgbaToInt(
                imageTemplate.bitmap.data[idx],
                imageTemplate.bitmap.data[idx+1],
                imageTemplate.bitmap.data[idx+2],
                imageTemplate.bitmap.data[idx+3],
            )
            let newPixelColourHex = colourHashMap.get(pixelColourHex);

            if(newPixelColourHex == undefined) {
                if(pixelColourHex != 0) {
                    if (pixelColourHex != 255) console.log(Jimp.intToRGBA(pixelColourHex));
                }
                newPixelColourHex = pixelColourHex;
            }

            finalImage.setPixelColor(newPixelColourHex, x, y);
        });

        finalImage.write("finalImage.png");
    } catch(err) {
        // throw err;
        console.log(err);
    }
}

main();