import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";

import { BirdWikiPage, ReferralWikiPage } from "../../supabase/functions/WikiPage.ts";

describe("BirdWikiPage", () => {

    let birdWikiPage: BirdWikiPage;

    beforeAll(() => {

    })

    beforeEach(() => {
        birdWikiPage = new BirdWikiPage("Test bird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})

describe("ReferralWikiPage", () => {

    let referralPage: ReferralWikiPage;

    beforeAll(() => {

    })

    beforeEach(() => {
        referralPage = new ReferralWikiPage("Test bird", ["Test section"]);
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})