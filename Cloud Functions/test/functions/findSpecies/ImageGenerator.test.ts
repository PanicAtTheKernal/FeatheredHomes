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
import TestHelper from "../../TestHelper.ts";
import { fail } from "https://deno.land/std@0.214.0/assert/fail.ts";


describe("ImageGenerator", () => {
    const generateTests = describe("generate");
    const shapeIdTest = describe("shapeId");
    const imagesTest = describe("images");
    const unisexTest = describe("unisex");
    const colourMapsTest = describe("colourMaps");

    let supabaseStub: SinonStubbedInstance<Supabase>;
    let chatGPTStub: SinonStubbedInstance<ChatGPT>;
    let imageManipulatorStub: SinonStubbedInstance<ImageManipulator>;
    let colourMapStub: SinonStubbedInstance<ColourMap>;
    // let colourMapStub: SinonStub;
    let imageGenerator: ImageGenerator;


    beforeAll(() => {
        imageManipulatorStub = TestHelper.createImageManipulatorStub();
        colourMapStub = TestHelper.createColourMap();
        chatGPTStub = TestHelper.createChatGPTStub();
        supabaseStub = TestHelper.createSupabaseStub();
    })
    
    beforeEach(() => {
        TestHelper.setupImageManipulatorStub(imageManipulatorStub);
        TestHelper.setupColourMapStub(colourMapStub);
        TestHelper.setupChatGPTStub(chatGPTStub);
        TestHelper.setupSupabaseStub(supabaseStub);
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
        const fakeTemplateError = "No template found";
        supabaseStub.fetchShapeFromFamily.throws(fakeTemplateError);    
        imageGenerator.generate().catch((error: Error) => {
            assertEquals(error.message, `Sinon-provided ${fakeTemplateError}`);
        })
    })

    it(generateTests, "shapeId should not be an empty string", async () => {
        await imageGenerator.generate();
        assertEquals(imageGenerator.shapeId, TestHelper.fakeShapeId);
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
        await imageGenerator.generate();
        const imageValue = (imageGenerator.images as UnisexImage);
        assertEquals(imageValue.image, TestHelper.birdUrl);
    })

    it(generateTests, "images should return type GenderImages if bird appearance is not unisex, ", async () => {
        chatGPTStub.checkIfBirdAppearanceUnisex.resolves(false);
        await imageGenerator.generate();
        const imageValue = (imageGenerator.images as GenderImages);
        assertEquals(imageValue.male, TestHelper.birdUrl);
        assertEquals(imageValue.female, TestHelper.birdUrl);
    })

    it(shapeIdTest, "Throw error if shapeId hasn't been generated", () => {
        try {
            imageGenerator.shapeId;
            fail();
        } catch (_error) {
            assert(true);
        }
    })

    it(imagesTest, "Throw error if images hasn't been generated", () => {
        try {
            imageGenerator.images;
            fail();
        } catch (_error) {
            assert(true);
        }
    })

    it(unisexTest, "Throw error if shapeId hasn't been generated", () => {
        try {
            imageGenerator.unisex;
            fail();
        } catch (_error) {
            assert(true);
        }
    })

    it(colourMapsTest, "Throw error if images hasn't been generated", () => {
        try {
            imageGenerator.colourMaps;
            fail();
        } catch (_error) {
            assert(true);
        }
    })
})