import { assert, assertEquals, fail } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { ColourMap } from "../../../supabase/functions/findSpecies/ColourMap.ts";
import { error } from "node:console";

describe("ColourMap", () => {

    let colourMap: ColourMap

    beforeAll(() => {
        TestHelper.createImageStub();
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

    it("Should return the fake colour map", () => {
        colourMap.createMap();
        assertEquals(colourMap.colourMap, TestHelper.fakeColourMapHex);
    })

    it("Should return 255 if the colour map has 255", () => {
        colourMap.createMap();
        assertEquals(colourMap.getValue(255), 255);
    })

    it("Should throw an error if an invalid hex code was passed into the colour map", () => {
        const invalidMap = new Map(
            [["#FFFFFF","Pink"],["#000000","00ff00"]]
        );
        colourMap = new ColourMap(invalidMap, TestHelper.fakeColourMap)
        try {
            colourMap.createMap();
            fail();
        } catch (error) {
            assertEquals(error.message, `Fail to parse invalid hexcode Pink`)
        }
    })

    it("Should throw an error if an hex code has less than 3 hex values", () => {
        const invalidMap = new Map(
            [["#FFFFFF","#FFFF"],["#000000","00ff00"]]
        );
        colourMap = new ColourMap(invalidMap, TestHelper.fakeColourMap)
        try {
            colourMap.createMap();
            fail();
        } catch (error) {
            assertEquals(error.message, `Fail to parse invalid hexcode #FFFF`)
        }
    })

    it("Should throw an error if there is a missing keyd in the template map", () => {
        const invalidMap = new Map(
            [["#FFFFFF","#FFFFFF"],["RED","#00ff00"]]
        );
        colourMap = new ColourMap(TestHelper.fakeColourMap, invalidMap);
        try {
            colourMap.createMap();
            fail();
        } catch (_error) {
            assert(true);
        }
    })
})