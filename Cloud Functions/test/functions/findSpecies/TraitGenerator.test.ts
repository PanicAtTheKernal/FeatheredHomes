import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { TraitGenerator } from "../../../supabase/functions/findSpecies/TraitGenerator.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../../../supabase/functions/OpenAIClient.ts";

describe("TraitGenerator", () => {
    let supabaseStub: SinonStubbedInstance<Supabase>;
    let chatGPTStub: SinonStubbedInstance<ChatGPT>;

    let traitGenerator: TraitGenerator;

    beforeAll(() => {
        supabaseStub = TestHelper.createSupabaseStub();
        chatGPTStub = TestHelper.createChatGPTStub();
    })

    beforeEach(() => {
        TestHelper.setupChatGPTStub(chatGPTStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        traitGenerator = new TraitGenerator("Test description", "Test bird");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("Should generate fake traits obj", async () => {
        await traitGenerator.generateTraits();
        assertEquals(traitGenerator.birdTraits, TestHelper.fakeTraits);
    })
})