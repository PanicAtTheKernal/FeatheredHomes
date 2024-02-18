import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";
import { WikiParser } from "../../supabase/functions/WikiParser.ts";


describe("WikiParser", () => {

    let wikiParser: WikiParser;

    beforeAll(() => {

    })

    beforeEach(() => {
        wikiParser = new WikiParser("Wiki page");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})