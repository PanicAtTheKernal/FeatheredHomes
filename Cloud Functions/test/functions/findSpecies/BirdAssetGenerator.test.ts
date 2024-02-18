import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { BirdAssetGenerator } from "../../../supabase/functions/findSpecies/BirdAssetGenerator.ts"
import { BirdWikiPage } from "../../../supabase/functions/WikiPage.ts";

describe("BirdAssetGenerator", () => {
    let birdWikiPageStub: SinonStubbedInstance<BirdWikiPage>; 

    let birdAssetGenerator: BirdAssetGenerator;

    beforeAll(() => {
        birdWikiPageStub = TestHelper.createBirdWikiPageStub();
    })

    beforeEach(() => {
        TestHelper.setupBirdWikiPageStub(birdWikiPageStub);
        birdAssetGenerator = new BirdAssetGenerator("testBird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})