import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts'


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

        const testColourHash = Image.rgbaToColor(testColourValue[0], testColourValue[1], testColourValue[2], alphaValue);
        const templateColourHash = Image.rgbaToColor(templateValue[0], templateValue[1], templateValue[2], alphaValue);

        colourHashMap.set(templateColourHash, testColourHash);
    })

    console.log(colourHashMap);
    return colourHashMap;
}
// Species 
async function main():Promise<void> {
    const colourHashMap: Map<number, number> = await createHashMapsOfColours();
    try {
        const testImage = await fetch("MISSING IMAGE URL").then(result => result.arrayBuffer()) as Buffer;
        const imageTemplate: Image = await Image.decode(testImage);
        const finalImage: Image = new Image(imageTemplate.width, imageTemplate.height);

        for(let x = 1; x <= imageTemplate.width; x++) {
            for(let y = 1; y <= imageTemplate.height; y++) {
                const colourValue = imageTemplate.getPixelAt(x,y);
                let newPixelColourHex = colourHashMap.get(colourValue);


                if(newPixelColourHex == undefined) {
                    if(colourValue != 0) {
                        if (colourValue != 255) console.log(Image.colorToRGBA(colourValue));
                    }
                    // Leave the colour as is incase the value wasn't found
                    newPixelColourHex = colourValue;
                }

                finalImage.setPixelAt(x, y, newPixelColourHex);
            }
    
        }

        const encoded =  await finalImage.encode()
        Deno.writeFile('./testImageScript.png', encoded);
        // imageTemplate.scan(0,0, imageTemplate.bitmap.width, imageTemplate.bitmap.height, (x, y, idx) => {
        //     const pixelColourHex:number = Jimp.rgbaToInt(
        //         imageTemplate.bitmap.data[idx],
        //         imageTemplate.bitmap.data[idx+1],
        //         imageTemplate.bitmap.data[idx+2],
        //         imageTemplate.bitmap.data[idx+3],
        //     )
            // let newPixelColourHex = colourHashMap.get(pixelColourHex);

            // if(newPixelColourHex == undefined) {
            //     if(pixelColourHex != 0) {
            //         if (pixelColourHex != 255) console.log(Jimp.intToRGBA(pixelColourHex));
            //     }
            //     newPixelColourHex = pixelColourHex;
            // }

        //     finalImage.setPixelColor(newPixelColourHex, x, y);
        // });

        // finalImage.write("finalImage.png");
    } catch(err) {
        // throw err;
        console.log(err);
    }
}

main();