import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { LabelDetection } from "../../../supabase/functions/imageIdentification/index.ts";

describe("LabelDetection", () => {

    let denoEnvStub: SinonStubbedInstance<Deno.Env>;
    let labelDetection: LabelDetection;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
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
})