import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { Search } from "../../../supabase/functions/search/index.ts";
import { RequestValidator } from "../../../supabase/functions/RequestValidator.ts";
import { LabelSorter } from "../../../supabase/functions/LabelSorter.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";

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
    let labelSorterStub: SinonStubbedInstance<LabelSorter>;
    let supabaseStub: SinonStubbedInstance<Supabase>;

    let search: Search;

    beforeAll(() => {
        labelSorterStub = TestHelper.createLabelSorterStub();
        supabaseStub = TestHelper.createSupabaseStub();
    })

    beforeEach(() => {
        TestHelper.setupLabelSorterStub(labelSorterStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        search = new Search("Test bird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });


    it("should return fake label if specific species is found", async () => {
        const result = await search.findBird();
        assertEquals(result.speciesName, TestHelper.fakeLabel);
        assertEquals(result.isValid, true);
    })

    it("should return fake label if no specific species is found", async () => {
        const fakeSortedLabelWithFamily = TestHelper.fakeSortedLabels;
        fakeSortedLabelWithFamily.birdSpeciesLabels = [];
        sinon.stub(labelSorterStub, "sortedLabels").get(() => fakeSortedLabelWithFamily);
        const result = await search.findBird();
        assertEquals(result.speciesName, TestHelper.fakeLabel);
        assertEquals(result.isValid, true);
    })

    it("should throw an error when labels are", async () => {
        const fakeSortedLabelBlurry = TestHelper.fakeSortedLabels;
        fakeSortedLabelBlurry.birdFamilyLabels = [];
        fakeSortedLabelBlurry.birdSpeciesLabels = [];
        sinon.stub(labelSorterStub, "sortedLabels").get(() => fakeSortedLabelBlurry);
        const result = await search.findBird();
        assertEquals(result.isValid, false);
    })
})