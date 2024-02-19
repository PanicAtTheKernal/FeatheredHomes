import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../../TestHelper.ts";
import { DietGenerator } from "../../../supabase/functions/findSpecies/DietGenerator.ts";
import { Supabase } from "../../../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../../../supabase/functions/OpenAIClient.ts";


describe("DietGenerator", () => {
    let supabaseStub: SinonStubbedInstance<Supabase>;
    let chatGPTStub: SinonStubbedInstance<ChatGPT>;

    let dietGenerator: DietGenerator;

    beforeAll(() => {
        supabaseStub = TestHelper.createSupabaseStub();
        chatGPTStub = TestHelper.createChatGPTStub();
    })

    beforeEach(() => {
        TestHelper.setupChatGPTStub(chatGPTStub);
        TestHelper.setupSupabaseStub(supabaseStub);
        dietGenerator = new DietGenerator("Test description");
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it("should return fakeDietId", async () => {
        const result = await dietGenerator.generate();
        assertEquals(result, TestHelper.fakeDietId);
    })
})