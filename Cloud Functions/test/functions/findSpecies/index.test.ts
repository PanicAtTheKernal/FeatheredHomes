import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { FindSpecies } from "../../../supabase/functions/findSpecies/index.ts";
import { RequestValidator } from "../../../supabase/functions/RequestValidator.ts";
import { BirdAssetGenerator } from "../../../supabase/functions/findSpecies/BirdAssetGenerator.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";


describe("index.ts", () => {
    const url = "http://localhost:8000/";

    let requestValidatorStub: SinonStubbedInstance<RequestValidator>;
    let findSpeciesStub: SinonStubbedInstance<FindSpecies>;

    beforeAll(() => {
        requestValidatorStub = TestHelper.createRequestValidatorStub();
        findSpeciesStub = sinon.stub(FindSpecies.prototype);
    })

    beforeEach(() => {
        TestHelper.setupRequestValidator(requestValidatorStub);
        findSpeciesStub.getBird.resolves(TestHelper.fakeBird);
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("Should return the fake bird", async () => {
        const result = await fetch(new Request(url, {
            body: "{ birdSpecies: \"Test Bird\"}", 
            method: "POST",
        }));
        assertEquals(await result.json(), TestHelper.fakeBird);
    })

    it("Should return error response if validator fails", async () => {
        requestValidatorStub.validate.resolves(new Response(
            JSON.stringify({
                error: TestHelper.fakeError
            })
        ))
        const result = await fetch(new Request(url, {
            body: "{ birdSpecies: \"Test Bird\"}", 
            method: "POST",
        }));
        assertEquals((await result.json()).error, TestHelper.fakeError);
    })

    it("Should return error response if fetchSpecies fails", async () => {
        findSpeciesStub.getBird.throws(TestHelper.fakeError);
        const result = await fetch(new Request(url, {
            body: "{ birdSpecies: \"Test Bird\"}", 
            method: "POST",
        }));
        assertEquals((await result.json()).error, "Sinon-provided " + TestHelper.fakeError);
    })
})

describe("FindSpecies", () => {
    let birdAssetGeneratorStub: SinonStubbedInstance<BirdAssetGenerator>;
    let supabaseStub: SinonStubbedInstance<Supabase>;

    let findSpecies: FindSpecies;

    beforeAll(() => {
        birdAssetGeneratorStub = TestHelper.createBirdAssetGeneratorStub();
        supabaseStub = TestHelper.createSupabaseStub();
    })

    beforeEach(() => {
        TestHelper.setupBirdAssetGeneratorStub(birdAssetGeneratorStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        findSpecies = new FindSpecies("Test name");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("should fetch fake bird", async () => {
        assertEquals(await findSpecies.getBird(), TestHelper.fakeBird);
    })
    
    it("should generate fake bird", async () => {
        supabaseStub.fetchBirdSpecies.resolves(null);
        assertEquals(await findSpecies.getBird(), TestHelper.fakeBird);
    })
})