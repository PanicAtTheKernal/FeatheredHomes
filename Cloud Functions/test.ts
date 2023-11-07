import { OpenAI } from "npm:openai@4.16.1";
import { load } from "https://deno.land/std@0.202.0/dotenv/mod.ts";

const env = await load();
const OPENAI_API_KEY = env["OPENAI_API_KEY"];

const openai = new OpenAI({
    apiKey: OPENAI_API_KEY,
});

async function main() {
  const response = await openai.chat.completions.create({
    model: "gpt-4-vision-preview",
    messages: [
        {
            role: "system",
            content: [
                { type: "text", text: `
                You will given a text description of a bird and a picture of template. Your role is to extract colour information from the description of the various parts of the bird then store the rgb value as an array in the to corresponding body part in the json structure defined here which corresponds with given image"
                {
                    "Crown": [255,126,0],
                    "UpperSupercilium": [133, 98, 61],
                    "MiddleSupercilium": [255,163,177],
                    "LowerSupercilium": [79, 36, 69],
                    "Nape": [237,28,36],
                    "Nostril": [255,194,14],
                    "UpperBeak": [168,230,29],
                    "LowerBeak": [34,177,76],
                    "Auriculars": [255,242,0],
                    "Throat": [47,54,153],
                    "Breast": [153,217,234],
                    "Wing": [255,249,189],
                    "Side": [229,170,122],
                    "Belly": [84,109,142], 
                    "Thigh": [156,90,60],
                    "Leg": [0,183,239],
                    "UndertailCoverts": [245,228,156],
                    "Tail": [211,249,188],
                    "Rump": [180,180,180],
                    "Flanks": [111, 49, 152]
                }                
". If the description does not define the colour you can use the colour of the closest body part instead within reason. The legs are a different colour from the feathers, if not defined just use the common leg colour of the bird type. Don't use max or min values like [255,255,255] or [0,0,0] etc. Also note that synonyms may be used in the description. Prefer males. No null values. Just the json.
                `}
            ]
        },
      {
        role: "user",
        content: [
          { type: "text", text: "The Eurasian blue tit is usually 12 cm (4.7 in), long with a wingspan of 18 cm (7.1 in) for both sexes, and weighs about 11 g (0.39 oz).[10] A typical Eurasian blue tit has an azure-blue crown and dark blue line passing through the eye, and encircling the white cheeks to the chin, giving the bird a very distinctive appearance. The forehead and a bar on the wing are white. The nape, wings and tail are blue and the back is yellowish green. The underparts are mostly sulphur-yellow with a dark line down the abdomen—the yellowness is indicative of the number of yellowy-green caterpillars eaten, due to high levels of carotene pigments in the diet.[11] The bill is black, the legs bluish grey, and the irides dark brown. The sexes are similar and often indistinguishable to human eyes, but under ultraviolet light, males have a brighter blue crown.[12] Young blue tits are noticeably more yellow. " },
          {
            type: "image_url",
            image_url:
              "https://sjiikegnbgahukdwklux.supabase.co/storage/v1/object/sign/BirdAssets/Templates/Chickadees/chickadees-sprite-sheet.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJCaXJkQXNzZXRzL1RlbXBsYXRlcy9DaGlja2FkZWVzL2NoaWNrYWRlZXMtc3ByaXRlLXNoZWV0LnBuZyIsImlhdCI6MTY5OTMwNTQ0MSwiZXhwIjoxNjk5OTEwMjQxfQ.DqC3gbFYAdniVVk0UO8RnaYF-pslhHaM3hnG4CR2suY&t=2023-11-06T21%3A17%3A21.434Z",
          },
        ],
      },
    ],
    max_tokens: 500
  });
  console.log(response.choices[0]);
  let write = JSON.stringify(response.choices[0]);
  await Deno.writeTextFile("result.json", write);
}

  
  main();