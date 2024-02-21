import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { LabelDetection } from "../../../supabase/functions/imageIdentification/LabelDetection.ts";

describe("LabelDetection", () => {

    let denoEnvStub: SinonStubbedInstance<Deno.Env>;
    let labelDetection: LabelDetection;
    let fetchStub: SinonStub;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
        fetchStub = sinon.stub(window, "fetch");
    })

    beforeEach(() => {
        TestHelper.setDenoEnvStub(denoEnvStub);
        labelDetection = new LabelDetection(new ArrayBuffer(4));
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("should throw an error if fetch response has a error property", async () => {
        const fakeResponse = new Response(JSON.stringify({
            error: {
                message: TestHelper.fakeError
            }
        }), {
            status: 200,
            headers: {'Content-Type': 'application/json'}
        })
        fetchStub.resolves(fakeResponse);
        await labelDetection.sendLabelDetectionRequest().catch((error) => {
            assertEquals(error.message, "Label Detection: " + TestHelper.fakeError)
        })
    })

    it("should throw an error if fetch response is missing labels", async () => {
        const fakeResponse = new Response(JSON.stringify({
            responses: [
                {
                    labelAnnotations: undefined
                }
            ]
        }), {
            status: 200,
            headers: {'Content-Type': 'application/json'}
        })
        fetchStub.resolves(fakeResponse);
        await labelDetection.sendLabelDetectionRequest().catch((error) => {
            assertEquals(error.message, "Label Detection: Result is missing properties")
        })
    })

    it("should return label map", async () => {
        const fakeResponse = new Response(JSON.stringify({
            responses: [
                {
                    labelAnnotations: [TestHelper.fakeLabelAnnotation]
                }
            ]
        }), {
            status: 200,
            headers: {'Content-Type': 'application/json'}
        })
        fetchStub.resolves(fakeResponse);
        await labelDetection.sendLabelDetectionRequest()
        const result = labelDetection.getLabelDetectionResults();
        assertEquals(result, TestHelper.fakeLabelMap);
    })
})