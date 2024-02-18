import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ImageIdentification } from "../../../supabase/functions/imageIdentification/index.ts";


describe("ImageIdentification", () => {
    let denoEnvStub: SinonStubbedInstance<Deno.Env>;

    let imageIdentification: ImageIdentification;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
    })

    beforeEach(() => {
        TestHelper.setDenoEnvStub(denoEnvStub);
        imageIdentification = new ImageIdentification(new ArrayBuffer(4));
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})