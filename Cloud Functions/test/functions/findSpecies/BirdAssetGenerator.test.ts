import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { BirdAssetGenerator } from "../../../supabase/functions/findSpecies/BirdAssetGenerator.ts"
import { BirdWikiPage } from "../../../supabase/functions/WikiPage.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../../../supabase/functions/OpenAIClient.ts";
import { ImageGenerator } from "../../../supabase/functions/findSpecies/ImageGenerator.ts";
import { DietGenerator } from "../../../supabase/functions/findSpecies/DietGenerator.ts";
import { TraitGenerator } from "../../../supabase/functions/findSpecies/TraitGenerator.ts";
import { assertNotEquals } from "https://deno.land/std@0.214.0/assert/assert_not_equals.ts";
import { assert } from "https://deno.land/std@0.214.0/assert/assert.ts";

describe("BirdAssetGenerator", () => {
    let birdWikiPageStub: SinonStubbedInstance<BirdWikiPage>; 
    let supabaseStub: SinonStubbedInstance<Supabase>;
    let imageGeneratorStub: SinonStubbedInstance<ImageGenerator>;
    let dietGeneratorStub: SinonStubbedInstance<DietGenerator>;
    let traitGeneratorStub: SinonStubbedInstance<TraitGenerator>;
    let chatGPTStub: SinonStubbedInstance<ChatGPT>;

    let birdAssetGenerator: BirdAssetGenerator;

    beforeAll(() => {
        birdWikiPageStub = TestHelper.createBirdWikiPageStub();
        supabaseStub = TestHelper.createSupabaseStub();
        imageGeneratorStub = TestHelper.createImageGeneratorStub();
        dietGeneratorStub = TestHelper.createDietGeneratorStub();
        traitGeneratorStub = TestHelper.createTraitGeneratorStub();
        chatGPTStub = TestHelper.createChatGPTStub();
    })

    beforeEach(() => {
        TestHelper.setupBirdWikiPageStub(birdWikiPageStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        TestHelper.setupImageGeneratorStub(imageGeneratorStub);
        TestHelper.setupDietGeneratorStub(dietGeneratorStub);
        TestHelper.setupTraitGeneratorStub(traitGeneratorStub);
        TestHelper.setupChatGPTStub(chatGPTStub);
        birdAssetGenerator = new BirdAssetGenerator("testBird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("Should generate a bird asset", async () => {
        await birdAssetGenerator.generate();
        const bird = birdAssetGenerator.generatedBird;
        assertNotEquals(bird.birdId, "");
    })

    it("Should call BirdWikiPage setupParser", async () => {
        await birdAssetGenerator.setupGenerator();
        assert(birdWikiPageStub.setupParser.called);
    })
})