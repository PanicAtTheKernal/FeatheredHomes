import { assert, assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ImageManipulator } from "../../../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../../../supabase/functions/findSpecies/ColourMap.ts";
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';

describe("ImageManipulator", () => {
    let colourMapStub: SinonStubbedInstance<ColourMap>;
    let imageStub : SinonStubbedInstance<Image>;
    let fetchStub : SinonStub;

    let imageManipulator: ImageManipulator;

    beforeAll(() => {
        colourMapStub = TestHelper.createColourMap();
        imageStub = TestHelper.createImageStub();
        fetchStub = sinon.stub(window, "fetch");
        sinon.replace(Image, "decode", sinon.fake.resolves(imageStub));
    })
    
    beforeEach(() => {
        const fakeResponse = new Response(new ArrayBuffer(4), {
            status: 200,
            headers: {'Content-Type': 'application/json'}
        })
        fetchStub.resolves(fakeResponse);
        TestHelper.setupColourMapStub(colourMapStub);
        TestHelper.setupImageStub(imageStub);
        imageManipulator = new ImageManipulator("test", colourMapStub);
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("Should return an 8bit array", async () => {
        const result = await imageManipulator.modifyImage();
        assert(result.byteLength == 4);
    })

    it("Should still return an 8bit array even with missing colours", async () => {
        colourMapStub.getValue.returns(undefined);
        const result = await imageManipulator.modifyImage();
        assert(result.byteLength == 4);
    })
})