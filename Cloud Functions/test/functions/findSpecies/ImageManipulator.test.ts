import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ImageManipulator } from "../../../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../../../supabase/functions/findSpecies/ColourMap.ts";

describe("ImageManipulator", () => {
    let colourMapStub: SinonStubbedInstance<ColourMap>;

    let imageManipulator: ImageManipulator;

    beforeAll(() => {
        colourMapStub = TestHelper.createColourMap();
    })

    beforeEach(() => {
        TestHelper.setupColourMapStub(colourMapStub);

        imageManipulator = new ImageManipulator("test", colourMapStub);
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})