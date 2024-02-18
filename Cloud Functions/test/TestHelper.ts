// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase } from "../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../supabase/functions/OpenAIClient.ts";
import { ImageManipulator } from "../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../supabase/functions/findSpecies/ColourMap.ts";
import { BirdWikiPage } from "../supabase/functions/WikiPage.ts";
import { BirdSpecies } from "../supabase/functions/SupabaseClient.ts";

const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
const fakeBirdShape: BirdShape = {
    BirdShapeName: "Bird",
    BirdShapeTemplateJson: {},
    BirdShapeTemplateUrl: "https://fakeBird.com"
}
const fakeBird: BirdSpecies = {
    birdId: "", 
    birdName: "",
    birdFamily: "",
    birdDescription: "",
    birdImages: { image: "" },
    birdScientificName: "",
    birdShapeId: "",
    birdSimulationInfo: [],
    createdAt: "",
    dietId: "",
    version: "",
    birdUnisex: true,
    birdColourMap: { image: "" }
};
const fakeColourMap = new Map(
    [["#000000","#FFFFFF"],["#FFFFFF","#000000"]]
)
const fakeColourMapNums = new Map(
    [[255,255], [255,255]]
)
const fakeColours = {
    beak: "#000000",
    belly: "#FFFFFF",
}
const fakeEnvGet = "OPEN-AI-API-KEY";
const birdUrl = "bird.url";
const fakeOpenAi = {
    checkIfBirdAppearanceUnisex: sinon.fake.returns("True"),
    generateColoursFromDescription: sinon.fake.returns(JSON.stringify(fakeColours))
}

function createChatGPTStub(): SinonStubbedInstance<ChatGPT> {
    let chatGPTStub = sinon.createStubInstance(ChatGPT);
    sinon.replace(ChatGPT, "instantiate", sinon.fake.returns(chatGPTStub));
    return chatGPTStub;
}

function createSupabaseStub(): SinonStubbedInstance<Supabase> {
    let supabaseStub = sinon.createStubInstance(Supabase);
    sinon.replace(Supabase, "instantiate", sinon.fake.returns(supabaseStub));
    return supabaseStub;
}

function createImageManipulatorStub(): SinonStubbedInstance<ImageManipulator> {
    return sinon.stub(ImageManipulator.prototype);
}

function createColourMap(): SinonStubbedInstance<ColourMap> {
    return sinon.stub(ColourMap.prototype);
}

function createBirdWikiPageStub(): SinonStubbedInstance<BirdWikiPage> {
    return sinon.stub(BirdWikiPage.prototype);
}

function createDenoEnvStub(): SinonStubbedInstance<Deno.Env> {
    return sinon.stub(Deno.env);
}

function setupChatGPTStub(chatGPTStub: SinonStubbedInstance<ChatGPT>): void {
    chatGPTStub.checkIfBirdAppearanceUnisex.resolves(true);
    chatGPTStub.generateSimplifiedSummary.resolves("Test summary");
    chatGPTStub.generateColoursFromDescription.resolves(JSON.stringify(fakeColours));
}

function setupSupabaseStub(supabaseStub: SinonStubbedInstance<Supabase>): void {
    supabaseStub.fetchShapeFromFamily.resolves(fakeShapeId);
    supabaseStub.fetchBirdShape.resolves(fakeBirdShape);
    supabaseStub.uploadBirdImage.resolves(birdUrl);
}

function setupImageManipulatorStub(imageManipulatorStub: SinonStubbedInstance<ImageManipulator>): void {
    imageManipulatorStub.modifyImage.resolves(new Uint8Array(2));
}

function setupColourMapStub(colourMapStub: SinonStubbedInstance<ColourMap>): void {
    colourMapStub.getValue.returns(255);
    sinon.stub(colourMapStub, "colourMap").get(() => fakeColourMap);
}

function setupBirdWikiPageStub(birdWikiPage: SinonStubbedInstance<BirdWikiPage>): void {
    birdWikiPage.getBirdSummary.returns("Test summary");
    birdWikiPage.getBirdScientificName.returns("Test Bird");
    birdWikiPage.getBehaviourSection.resolves("Test Section");
    birdWikiPage.getBirdFamily.returns("Test Family");
    birdWikiPage.getBirdName.returns("Test name");
    birdWikiPage.getBirdSpecies.returns("Test species");
    birdWikiPage.getDefaultBirdName.resolves("Test default name");
    birdWikiPage.getDescription.resolves("Test description");
    birdWikiPage.isBirdFamily.resolves(true);
    birdWikiPage.isBirdSpecies.resolves(true);
    birdWikiPage.isPageAboutBirds.resolves(true);
}

function setDenoEnvStub(denoEnvStub: SinonStubbedInstance<Deno.Env>): void {
    denoEnvStub.get.returns(fakeEnvGet);
}

export default { 
    fakeShapeId,
    fakeBirdShape,
    fakeColourMap,
    fakeColours,
    fakeBird,
    birdUrl,
    fakeColourMapNums,
    fakeOpenAi,
    fakeEnvGet,
    createChatGPTStub,
    createSupabaseStub, 
    createImageManipulatorStub,
    createColourMap,
    createBirdWikiPageStub,
    createDenoEnvStub,
    setupChatGPTStub,
    setupSupabaseStub,
    setupImageManipulatorStub,
    setupColourMapStub,
    setupBirdWikiPageStub,
    setDenoEnvStub,
}