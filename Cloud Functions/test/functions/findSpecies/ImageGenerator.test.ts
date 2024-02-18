import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
import console, { assert } from "node:console";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase, UnisexImage, GenderImages } from "../../../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../../../supabase/functions/OpenAIClient.ts";
import { ImageGenerator } from "../../../supabase/functions/findSpecies/ImageGenerator.ts";
import { assertThrows } from "https://deno.land/std@0.214.0/assert/assert_throws.ts";
import { ImageManipulator } from "../../../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../../../supabase/functions/findSpecies/ColourMap.ts";
import Sinon from "npm:@types/sinon";
import { assertNotEquals } from "https://deno.land/std@0.214.0/assert/assert_not_equals.ts";


describe("ImageGenerator", () => {
    const generateTests = describe("generate");

    const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
    const fakeBirdShape: BirdShape = {
        BirdShapeName: "Bird",
        BirdShapeTemplateJson: {},
        BirdShapeTemplateUrl: "https://fakeBird.com"
    }
    const fakeTemplateError = "No template found";
    const fakeColours = {
        beak: "#000000",
        belly: "#FFFFFF",
    }
    const fakeColourMap = new Map(
        [["#000000","#FFFFFF"],["#FFFFFF","#000000"]])
    const fakeOpenAi = {
        checkIfBirdAppearanceUnisex: sinon.fake.returns("True"),
        generateColoursFromDescription: sinon.fake.returns(JSON.stringify(fakeColours))
    }
    let supabaseStub: SinonStubbedInstance<Supabase>;
    let chatGPTStub: SinonStubbedInstance<ChatGPT>;
    let imageManipulatorStub: SinonStubbedInstance<ImageManipulator>;
    let colourMapStub: SinonStubbedInstance<ColourMap>;
    // let colourMapStub: SinonStub;
    let imageGenerator: ImageGenerator;


    beforeAll(() => {
        imageManipulatorStub = sinon.stub(ImageManipulator.prototype);
        colourMapStub = sinon.stub(ColourMap.prototype);
        chatGPTStub = sinon.createStubInstance(ChatGPT);
        supabaseStub = sinon.createStubInstance(Supabase);
        sinon.replace(ChatGPT, "instantiate", sinon.fake.returns(chatGPTStub));
        sinon.replace(Supabase, "instantiate", sinon.fake.returns(supabaseStub));
    })
    
    beforeEach(() => {
        // ImageManipulator
        imageManipulatorStub.modifyImage.resolves(new Uint8Array(2));
        // ColourMap
        colourMapStub.getValue.returns(255);
        sinon.stub(colourMapStub, "colourMap").get(() => fakeColourMap);
        // ChatGPT
        chatGPTStub.checkIfBirdAppearanceUnisex.resolves(true);
        chatGPTStub.generateColoursFromDescription.resolves(JSON.stringify(fakeColours));
        //Supabase
        supabaseStub.fetchShapeFromFamily.resolves(fakeShapeId);
        supabaseStub.fetchBirdShape.resolves(fakeBirdShape);
        // This should always be last
        imageGenerator = new ImageGenerator("testDescription", "testFamily", "testName");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
    
    it(generateTests, "generate should throw error when template is not found", () => {
        supabaseStub.fetchShapeFromFamily.throws(fakeTemplateError);    
        imageGenerator.generate().catch((error: Error) => {
            assertEquals(error.message, `Sinon-provided ${fakeTemplateError}`);
        })
    })

    it(generateTests, "shapeId should not be an empty string", async () => {
        await imageGenerator.generate();
        assertEquals(imageGenerator.shapeId, fakeShapeId);
    })

    it(generateTests, "unisex should return true if chatGPT says it's true", async () => {
        await imageGenerator.generate();
        assertEquals(imageGenerator.unisex, true);
    })

    it(generateTests, "unisex should return false if chatGPT says it's false", async () => {
        chatGPTStub.checkIfBirdAppearanceUnisex.resolves(false);
        await imageGenerator.generate();
        assertEquals(imageGenerator.unisex, false);
    })

    // Test for unisex and gendered images
    it(generateTests, "images should return type UnisexImage if chatGPT says bird is unisex", async () => {
        const unisexUrl = "unisex.asdf";
        supabaseStub.uploadBirdImage.resolves(unisexUrl);
        await imageGenerator.generate();
        const imageValue = (imageGenerator.images as UnisexImage);
        assertEquals(imageValue.image, unisexUrl);
    })

    // Test for colourMaps
})