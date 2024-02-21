import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";
import { LabelSorter } from "../../supabase/functions/LabelSorter.ts";
import { BirdWikiPage, ReferralWikiPage } from "../../supabase/functions/WikiPage.ts";
import { Supabase } from "../../supabase/functions/SupabaseClient.ts";
import { assert } from "node:console";

describe("LabelSorter", () => {
    let birdWikiPageStub: SinonStubbedInstance<BirdWikiPage>;
    let referralWikiPageStub: SinonStubbedInstance<ReferralWikiPage>;
    let supabaseStub: SinonStubbedInstance<Supabase>;

    let labelSorter: LabelSorter;

    beforeAll(() => {
        birdWikiPageStub = TestHelper.createBirdWikiPageStub();
        try {
            referralWikiPageStub = TestHelper.createReferralWikiPageStub();
        } catch (_error) {}
        supabaseStub = TestHelper.createSupabaseStub();
    })

    beforeEach(() => {
        TestHelper.setupBirdWikiPageStub(birdWikiPageStub);
        try {
            TestHelper.setupReferralWikiPageStub(referralWikiPageStub);
        } catch (_error) {}
        TestHelper.setupSupabaseStub(supabaseStub);
        labelSorter = new LabelSorter();
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("should sort labels", async () => {
        await labelSorter.sort(["Bird", TestHelper.fakeLabel, "FakeFamily", "Forbidden label"]);
        console.log(labelSorter.sortedLabels);
        assert(true);
    })
})