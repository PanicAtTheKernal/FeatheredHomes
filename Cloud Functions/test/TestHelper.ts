// @deno-types="npm:@types/sinon"
import sinon, { SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase } from "../supabase/functions/SupabaseClient.ts";
import { ChatGPT } from "../supabase/functions/OpenAIClient.ts";
import { ImageManipulator } from "../supabase/functions/findSpecies/ImageManipulator.ts";
import { ColourMap } from "../supabase/functions/findSpecies/ColourMap.ts";
import { BirdWikiPage, ReferralWikiPage } from "../supabase/functions/WikiPage.ts";
import { BirdSpecies } from "../supabase/functions/SupabaseClient.ts";
import { ImageGenerator } from "../supabase/functions/findSpecies/ImageGenerator.ts";
import { DietGenerator } from "../supabase/functions/findSpecies/DietGenerator.ts";
import { TraitGenerator } from "../supabase/functions/findSpecies/TraitGenerator.ts";
import { Image } from 'https://deno.land/x/imagescript@1.2.15/mod.ts';
import { RequestValidator } from "../supabase/functions/RequestValidator.ts";
import { BirdAssetGenerator } from "../supabase/functions/findSpecies/BirdAssetGenerator.ts";
import { LabelDetection } from "../supabase/functions/imageIdentification/LabelDetection.ts";
import { LabelSorter } from "../supabase/functions/LabelSorter.ts";

const fakeShapeId = "848c3291-8e0e-403b-8372-1b0a416edf0f";
const fakeDiets = ["FakeFood"];
const fakeDietId = "848c3291-8e0e-403b-3245-1a4b367daa45";
const fakeBirdShape: BirdShape = {
    BirdShapeName: "Bird",
    BirdShapeTemplateJson: {},
    BirdShapeTemplateUrl: "https://fakeBird.com"
}
const fakeSearchResponse = {
    isValid: true,
    speciesName: "Test Bird",
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
const fakeError = "Error";
const fakeEnvGet = "OPEN-AI-API-KEY";
const fakeSystemMessage = "System message";
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
const fakeTraitsList = ["fakeTrait"];
const fakeLabel = "FakeLabel";
const fakeLabels = [fakeLabel];
const fakeFamilyLabels = new Map(
    [["FakeFamily",fakeLabel]]
)
const fakeBlacklistedLabels = ["Forbidden label"]
const fakeImageIdentificationResponse = {
    isBird: true,
    birdSpecies: "Test bird",
    approximate: false,
    error: ""
}
const fakeLabelAnnotation = {
    description: "Fake label",
    mid: "string",
    score: 0.8,
    topicality: 0.8
}
const fakeLabelMap = new Map(
    [[fakeLabelAnnotation.description, fakeLabelAnnotation.score]]
)
const fakeSortedLabels = {
    isBird: true,
    birdSpeciesLabels: [fakeLabel],
    birdFamilyLabels: ["FakeFamily"],
}
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

function createImageStub(): SinonStubbedInstance<Image> {
    sinon.replace(Image, "rgbaToColor", sinon.fake.returns(255));
    const fakeImage = sinon.stub(Image.prototype);
    return fakeImage;
}


function createDenoEnvStub(): SinonStubbedInstance<Deno.Env> {
    return sinon.stub(Deno.env);
}

function createRequestValidatorStub(): SinonStubbedInstance<RequestValidator> {
    return sinon.stub(RequestValidator.prototype);
}

function createBirdAssetGeneratorStub(): SinonStubbedInstance<BirdAssetGenerator> {
    return sinon.stub(BirdAssetGenerator.prototype);
}

function createLabelDetectionStub(): SinonStubbedInstance<LabelDetection> {
    return sinon.stub(LabelDetection.prototype);
}

function createLabelSorterStub(): SinonStubbedInstance<LabelSorter> {
    return sinon.stub(LabelSorter.prototype);
}

function createReferralWikiPageStub(): SinonStubbedInstance<ReferralWikiPage> {
    return sinon.stub(ReferralWikiPage.prototype);
}
// Setup stubs

function setupChatGPTStub(chatGPTStub: SinonStubbedInstance<ChatGPT>): void {
    chatGPTStub.checkIfBirdAppearanceUnisex.resolves(true);
    chatGPTStub.generateSimplifiedSummary.resolves("Test summary");
    chatGPTStub.generateColoursFromDescription.resolves(JSON.stringify(fakeColours));
    chatGPTStub.generateCustomSummary.resolves("Shorten description");
    chatGPTStub.generateTraits.resolves("{ \"fakeTrait\": true }");
}

function setupSupabaseStub(supabaseStub: SinonStubbedInstance<Supabase>): void {
    supabaseStub.fetchShapeFromFamily.resolves(fakeShapeId);
    supabaseStub.fetchBirdShape.resolves(fakeBirdShape);
    supabaseStub.uploadBirdImage.resolves(birdUrl);
    supabaseStub.fetchDiets.resolves(fakeDiets);
    supabaseStub.fetchDietId.resolves(fakeDietId);
    supabaseStub.fetchTraits.resolves(fakeTraitsList);
    supabaseStub.fetchBirdSpecies.resolves(fakeBird);
    supabaseStub.fetchBirdFamilyLabels.resolves(fakeFamilyLabels);
    supabaseStub.fetchBirdSpeciesLabels.resolves(fakeLabels);
    supabaseStub.fetchBlacklistedLabels.resolves(fakeBlacklistedLabels);
    supabaseStub.fetchDefaultBirdName.resolves(fakeLabel);
    supabaseStub.fetchSystemMessage.resolves(fakeSystemMessage);
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

function setupImageStub(imageStub: SinonStubbedInstance<Image>): void {
    sinon.stub(imageStub, "width").get(() => 100);
    sinon.stub(imageStub, "height").get(() => 100);
    // @ts-ignore:  
    imageStub.encode.resolves(new ArrayBuffer(4));
}

function setDenoEnvStub(denoEnvStub: SinonStubbedInstance<Deno.Env>): void {
    denoEnvStub.get.returns(fakeEnvGet);
}

function setupRequestValidator(requestValidator: SinonStubbedInstance<RequestValidator>): void {
    requestValidator.validate.resolves(null);
    sinon.stub(requestValidator, "body").get(() => { return {birdSpecies: "Test Bird"}});
}

function setupBirdAssetGeneratorStub(birdAssetGenerator: SinonStubbedInstance<BirdAssetGenerator>): void {
    sinon.stub(birdAssetGenerator, "generatedBird").get(() => fakeBird);
}

function setupLabelDetectorStub(labelDetector: SinonStubbedInstance<LabelDetection>): void {
    labelDetector.getLabelDetectionResults.returns(fakeLabelMap);
}

function setupLabelSorterStub(labelSorter: SinonStubbedInstance<LabelSorter>): void {
    sinon.stub(labelSorter, "sortedLabels").get(() => fakeSortedLabels);
}

function setupReferralWikiPageStub(referralWikiPage: SinonStubbedInstance<ReferralWikiPage>): void {
    referralWikiPage.getFirstBirdReferralPage.returns(sinon.createStubInstance(BirdWikiPage));
    referralWikiPage.isReferralPage.returns(true);
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
    fakeError,
    fakeUnisexImage,
    fakeUnisexColours,
    fakeColourMapHex,
    fakeDietId,
    fakeTraits,
    fakeTraitsList,
    fakeLabel,
    fakeLabels,
    fakeFamilyLabels,
    fakeSearchResponse,
    fakeImageIdentificationResponse,
    fakeLabelAnnotation,
    fakeLabelMap,
    fakeSortedLabels,

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
    createRequestValidatorStub,
    createBirdAssetGeneratorStub,
    createLabelDetectionStub,
    createLabelSorterStub,
    createReferralWikiPageStub,

    setupChatGPTStub,
    setupSupabaseStub,
    setupImageManipulatorStub,
    setupColourMapStub,
    setupBirdWikiPageStub,
    setupImageGeneratorStub,
    setupDietGeneratorStub,
    setupTraitGeneratorStub,
    setupImageStub,
    setDenoEnvStub,
    setupRequestValidator,
    setupBirdAssetGeneratorStub,
    setupLabelDetectorStub,
    setupLabelSorterStub,
    setupReferralWikiPageStub,
}