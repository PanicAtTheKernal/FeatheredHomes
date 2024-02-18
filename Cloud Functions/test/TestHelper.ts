// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase } from "../supabase/functions/SupabaseClient.ts";

const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
const fakeBirdShape: BirdShape = {
    BirdShapeName: "Bird",
    BirdShapeTemplateJson: {},
    BirdShapeTemplateUrl: "https://fakeBird.com"
}

function createSupabaseStub(): SinonStubbedInstance<Supabase> {
    let supabaseStub = sinon.createStubInstance(Supabase);
    sinon.replace(Supabase, "instantiate", sinon.fake.returns(supabaseStub));
    return supabaseStub;
}

function setupSupabaseStub(supabaseStub: SinonStubbedInstance<Supabase>): void {
    supabaseStub.fetchShapeFromFamily.resolves(fakeShapeId);
    supabaseStub.fetchBirdShape.resolves(fakeBirdShape);
}

export default { 
    fakeShapeId,
    fakeBirdShape,
    createSupabaseStub, 
    setupSupabaseStub, 
}