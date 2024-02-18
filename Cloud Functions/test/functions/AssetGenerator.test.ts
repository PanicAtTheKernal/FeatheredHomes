import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";

// Integration test to test if all the modules generate bird, go as far supabase, bird wiki parser and openAI
describe("AssetGeneratorIntegration", () => {

    beforeAll(() => {

    })

    beforeEach(() => {

    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})