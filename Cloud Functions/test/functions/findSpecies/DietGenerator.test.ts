import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { DietGenerator } from "../../../supabase/functions/findSpecies/DietGenerator.ts";

describe("DietGenerator", () => {

    let dietGenerator: DietGenerator;

    beforeAll(() => {

    })

    beforeEach(() => {
        dietGenerator = new DietGenerator("Test description");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})