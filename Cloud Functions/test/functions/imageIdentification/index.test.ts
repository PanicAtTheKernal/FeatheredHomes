import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ImageIdentification } from "../../../supabase/functions/imageIdentification/index.ts";
import { LabelDetection } from "../../../supabase/functions/imageIdentification/LabelDetection.ts";
import { LabelSorter } from "../../../supabase/functions/LabelSorter.ts";
import { assert } from "https://deno.land/std@0.214.0/assert/assert.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";

// describe("index.ts", () => {
//     const url = "http://localhost:8000/";

//     let searchStub: SinonStubbedInstance<ImageIdentification>;
//     let supabaseStub: SinonStubbedInstance<Supabase>;

//     beforeAll(() => {
//         searchStub = sinon.stub(ImageIdentification.prototype);
//         supabaseStub = TestHelper.createSupabaseStub();
//     })

//     beforeEach(() => {
//         TestHelper.setupSupabaseStub(supabaseStub);
//         searchStub.getBirdName.resolves({ name: TestHelper.fakeImageIdentificationResponse.birdSpecies, approximate: false});
//     })

//     afterEach(() => {
//         sinon.reset();
//     })

//     afterAll(() => {
//         sinon.restore();
//     });

//     it("Should return the fake image id", async () => {
//         const result = await fetch(new Request(url, {
//             body: "{ birdSpecies: \"Test Bird\"}", 
//             method: "POST",
//         }));
//         assertEquals(await result.json(), TestHelper.fakeImageIdentificationResponse);
//     })

//     it("Should return error response if request is not a post method fails", async () => {
//         const result = await fetch(new Request(url, {
//             method: "GET",
//         }));
//         assertEquals((await result.json()).error, "Request must be a POST");
//     })

//     it("Should return error response if ImageIdentification fails", async () => {
//         searchStub.getBirdName.throws(TestHelper.fakeError);
//         const result = await fetch(new Request(url, {
//             body: "{ birdSpecies: \"Test Bird\"}", 
//             method: "POST",
//         }));
//         assertEquals((await result.json()).error, "Sinon-provided " + TestHelper.fakeError);
//     })
// })

describe("ImageIdentification", () => {
    const identifyLabelsInImageTest = describe("identifyLabelsInImage");
    const getBirdNameTest = describe("getBirdName");

    let denoEnvStub: SinonStubbedInstance<Deno.Env>;
    let labelDetectionStub: SinonStubbedInstance<LabelDetection>;
    let labelSorterStub: SinonStubbedInstance<LabelSorter>;
    let supabaseStub: SinonStubbedInstance<Supabase>;

    let imageIdentification: ImageIdentification;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
        labelDetectionStub = TestHelper.createLabelDetectionStub();
        labelSorterStub = TestHelper.createLabelSorterStub();
        supabaseStub = TestHelper.createSupabaseStub();
    })

    beforeEach(() => {
        TestHelper.setDenoEnvStub(denoEnvStub);
        TestHelper.setupLabelDetectorStub(labelDetectionStub);
        TestHelper.setupLabelSorterStub(labelSorterStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        imageIdentification = new ImageIdentification(new ArrayBuffer(4));
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it(identifyLabelsInImageTest, "should call getLabelDetectionResults", async () => {
        await imageIdentification.identifyLabelsInImage();
        assert(labelDetectionStub.getLabelDetectionResults.called)
    })

    it(getBirdNameTest, "should return fake label if specific species is found", async () => {
        await imageIdentification.identifyLabelsInImage();
        assertEquals((await imageIdentification.getBirdName()).name, TestHelper.fakeLabel);
        assertEquals((await imageIdentification.getBirdName()).approximate, false);
    })

    it(getBirdNameTest, "should return fake label if no specific species is found", async () => {
        await imageIdentification.identifyLabelsInImage();
        const fakeSortedLabelWithFamily = TestHelper.fakeSortedLabels;
        fakeSortedLabelWithFamily.birdSpeciesLabels = [];
        sinon.stub(labelSorterStub, "sortedLabels").get(() => fakeSortedLabelWithFamily);
        assertEquals((await imageIdentification.getBirdName()).name, TestHelper.fakeLabel);
        assertEquals((await imageIdentification.getBirdName()).approximate, true);
    })

    it(getBirdNameTest, "should throw an error when labels are", async () => {
        await imageIdentification.identifyLabelsInImage();
        const fakeSortedLabelBlurry = TestHelper.fakeSortedLabels;
        fakeSortedLabelBlurry.birdFamilyLabels = [];
        fakeSortedLabelBlurry.birdSpeciesLabels = [];
        sinon.stub(labelSorterStub, "sortedLabels").get(() => fakeSortedLabelBlurry);
        await imageIdentification.getBirdName().catch((error) => {
            assertEquals(error.message, "Blurry bird");
        });
    })
})