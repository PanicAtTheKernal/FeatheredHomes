// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase } from "../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../supabase/functions/OpenAIClient.ts";
import { ImageManipulator } from "../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../supabase/functions/findSpecies/ColourMap.ts";
import { BirdWikiPage } from "../supabase/functions/WikiPage.ts";
import { BirdSpecies } from "../supabase/functions/SupabaseClient.ts";
import { ImageGenerator } from "../supabase/functions/findSpecies/ImageGenerator.ts";
import { DietGenerator } from "../supabase/functions/findSpecies/DietGenerator.ts";
import { TraitGenerator } from "../supabase/functions/findSpecies/TraitGenerator.ts";
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';

const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
const fakeDiets = ["FakeFood"];
const fakeDietId = "848c3291-8e0e-403b-3245-1a4b367daa45";
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
const fakeColourMapHex = new Map(
    [["#000000","#000000"],["#FFFFFF","#FFFFFF"]]
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
const fakeUnisexImage = {
    "image": birdUrl
}
const fakeUnisexColours = {
    "image": fakeColourMap
}
const fakeTraits = new Map(
    [["fakeTrait", true]]
)
// Create stubs

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

function createImageGeneratorStub(): SinonStubbedInstance<ImageGenerator> {
    return sinon.stub(ImageGenerator.prototype);
}

function createDietGeneratorStub(): SinonStubbedInstance<DietGenerator> {
    return sinon.stub(DietGenerator.prototype);
}

function createTraitGeneratorStub(): SinonStubbedInstance<TraitGenerator> {
    return sinon.stub(TraitGenerator.prototype);
}

function createImageStub(): void {
    sinon.replace(Image, "rgbaToColor", sinon.fake.returns(255));
}

function createDenoEnvStub(): SinonStubbedInstance<Deno.Env> {
    return sinon.stub(Deno.env);
}

// Setup stubs

function setupChatGPTStub(chatGPTStub: SinonStubbedInstance<ChatGPT>): void {
    chatGPTStub.checkIfBirdAppearanceUnisex.resolves(true);
    chatGPTStub.generateSimplifiedSummary.resolves("Test summary");
    chatGPTStub.generateColoursFromDescription.resolves(JSON.stringify(fakeColours));
    chatGPTStub.generateCustomSummary.resolves("Shorten description");
}

function setupSupabaseStub(supabaseStub: SinonStubbedInstance<Supabase>): void {
    supabaseStub.fetchShapeFromFamily.resolves(fakeShapeId);
    supabaseStub.fetchBirdShape.resolves(fakeBirdShape);
    supabaseStub.uploadBirdImage.resolves(birdUrl);
    supabaseStub.fetchDiets.resolves(fakeDiets);
    supabaseStub.fetchDietId.resolves(fakeDietId);
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

function setupImageGeneratorStub(imageGeneratorStub: SinonStubbedInstance<ImageGenerator>): void {
    sinon.stub(imageGeneratorStub, "colourMaps").get(() => fakeUnisexColours);
    sinon.stub(imageGeneratorStub, "images").get(() => fakeUnisexImage);
    sinon.stub(imageGeneratorStub, "shapeId").get(() => fakeShapeId);
    sinon.stub(imageGeneratorStub, "unisex").get(() => false);
}

function setupDietGeneratorStub(dietGeneratorStub: SinonStubbedInstance<DietGenerator>): void {
    dietGeneratorStub.generate.resolves(fakeDietId);
}

function setupTraitGeneratorStub(traitGeneratorStub: SinonStubbedInstance<TraitGenerator>): void {
    sinon.stub(traitGeneratorStub, "birdTraits").get(() => fakeTraits);
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
    fakeUnisexImage,
    fakeUnisexColours,
    fakeColourMapHex,
    fakeDietId,
    fakeTraits,

    createChatGPTStub,
    createSupabaseStub, 
    createImageManipulatorStub,
    createColourMap,
    createBirdWikiPageStub,
    createDietGeneratorStub,
    createImageGeneratorStub,
    createTraitGeneratorStub,
    createImageStub,
    createDenoEnvStub,

    setupChatGPTStub,
    setupSupabaseStub,
    setupImageManipulatorStub,
    setupColourMapStub,
    setupBirdWikiPageStub,
    setupImageGeneratorStub,
    setupDietGeneratorStub,
    setupTraitGeneratorStub,
    setDenoEnvStub,
}