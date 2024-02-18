import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { FindSpecies } from "../../../supabase/functions/findSpecies/index.ts";

describe("FindSpecies", () => {

    let findSpecies: FindSpecies;

    beforeAll(() => {

    })

    beforeEach(() => {
        findSpecies = new FindSpecies("Test name");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})