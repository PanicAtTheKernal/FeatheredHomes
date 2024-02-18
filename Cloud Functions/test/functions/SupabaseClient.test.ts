import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import TestHelper from "../TestHelper.ts";
import { Supabase } from "../../supabase/functions/SupabaseClient.ts";


describe("Supabase", () => {
    let denoEnvStub: SinonStubbedInstance<Deno.Env>;

    let supabase: Supabase;

    beforeAll(() => {
        denoEnvStub = TestHelper.createDenoEnvStub();
    })

    beforeEach(() => {
        TestHelper.setDenoEnvStub(denoEnvStub);
        supabase = Supabase.instantiate();
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });
})