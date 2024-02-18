import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ColourMap } from "../../../supabase/functions/findSpecies/ColourMap.ts";

describe("ColourMap", () => {

    let colourMap: ColourMap

    beforeAll(() => {

    })

    beforeEach(() => {
        colourMap = new ColourMap(TestHelper.fakeColourMap, TestHelper.fakeColourMap);
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})