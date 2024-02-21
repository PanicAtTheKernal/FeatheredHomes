import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { Search } from "../../../supabase/functions/search/index.ts";
import { RequestValidator } from "../../../supabase/functions/RequestValidator.ts";

describe("index.ts", () => {
    const url = "http://localhost:8000/";

    let requestValidatorStub: SinonStubbedInstance<RequestValidator>;
    let searchStub: SinonStubbedInstance<Search>;

    beforeAll(() => {
        requestValidatorStub = TestHelper.createRequestValidatorStub();
        searchStub = sinon.stub(Search.prototype);
    })

    beforeEach(() => {
        TestHelper.setupRequestValidator(requestValidatorStub);
        searchStub.findBird.resolves(TestHelper.fakeSearchResponse);
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
        assertEquals(await result.json(), TestHelper.fakeSearchResponse);
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

    it("Should return error response if search fails", async () => {
        searchStub.findBird.throws(TestHelper.fakeError);
        const result = await fetch(new Request(url, {
            body: "{ birdSpecies: \"Test Bird\"}", 
            method: "POST",
        }));
        assertEquals((await result.json()).error, "Sinon-provided " + TestHelper.fakeError);
    })
})

describe("Search", () => {
    let denoEnvStub: SinonStubbedInstance<Deno.Env>;

    let search: Search;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
    })

    beforeEach(() => {
        TestHelper.setDenoEnvStub(denoEnvStub);
        search = new Search("Test bird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})