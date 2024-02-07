import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
import { assert } from "node:console";
import sinon from "npm:sinon";
import { BirdShape, Supabase } from "../../../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../../../supabase/functions/OpenAIClient.ts";
import { ImageGenerator } from "../../../supabase/functions/findSpecies/ImageGenerator.ts";
import { assertThrows } from "https://deno.land/std@0.214.0/assert/assert_throws.ts";


describe("ImageGenerator", () => {
    const generateTests = describe("generate");

    const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
    const fakeBirdShape: BirdShape = {
        BirdShapeName: "Bird",
        BirdShapeTemplateJson: {},
        BirdShapeTemplateUrl: "https://fakeBird.com"
    }
    const fakeTemplateError = "No template found";

    let imageGenerator: ImageGenerator;

    beforeEach(() => {
        imageGenerator = new ImageGenerator("test", "test");
    })

    afterEach(() => {
        sinon.restore()
    })

    it(generateTests, "shapeId should not be an empty string", async () => {
        const fakeOpenAi = {
            checkIfBirdAppearanceUnisex: sinon.fake.returns("yes")
        }
        const fakeSupabase = {
            fetchShapeFromFamily: sinon.fake.returns(fakeShapeId),
            fetchBirdShape: sinon.fake.returns(fakeBirdShape)
        }
        sinon.replace(Supabase, "instantiate", sinon.fake.returns(fakeSupabase))
        sinon.replace(ChatGPT, "instantiate", sinon.fake.returns(fakeOpenAi))
        await imageGenerator.generate();
        assertEquals(imageGenerator.shapeId, fakeShapeId);
    })

    it(generateTests, "generate should throw error when template is not found", async () => {
        const fakeOpenAi = {
            checkIfBirdAppearanceUnisex: sinon.fake.returns("yes")
        }
        const fakeSupabase = {
            fetchShapeFromFamily: sinon.fake.throws(fakeTemplateError),
            fetchBirdShape: sinon.fake.returns(fakeBirdShape)
        }
        sinon.replace(Supabase, "instantiate", sinon.fake.returns(fakeSupabase))
        sinon.replace(ChatGPT, "instantiate", sinon.fake.returns(fakeOpenAi))

        imageGenerator.generate().catch((error: Error) => {
            assertEquals(error.message, fakeTemplateError);
        })
    })
})