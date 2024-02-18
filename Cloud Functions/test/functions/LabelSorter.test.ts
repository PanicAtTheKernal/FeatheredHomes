import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";
import { LabelSorter } from "../../supabase/functions/LabelSorter.ts";

describe("LabelSorter", () => {

    let labelSorter: LabelSorter;

    beforeAll(() => {

    })

    beforeEach(() => {
        let labelSorter = new LabelSorter();
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})