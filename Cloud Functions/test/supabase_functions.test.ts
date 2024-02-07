import { assertEquals } from "https://deno.land/std@0.207.0/assert/mod.ts";
import { Stub, assertSpyCall, assertSpyCalls, spy, stub, } from "https://deno.land/std@0.207.0/testing/mock.ts";
import { parseWikiPage, _functions } from ".././supabase/functions/findSpecies/supabase_functions.ts";
import { BirdHelperFunctions, SupabaseFunctions, _webFunctions, BirdWikiPage } from ".././supabase/functions/findSpecies/supabase_helper_functions.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";

// const mockHtmkDir = "/test/mockHtml/"
// const path = Deno.cwd()+mockHtmkDir;


// describe("parseWikiPage", () => {
//     let fetchTextMock: Stub;
//     let fakeUrl: URL;
//     let sampleHtml: string;
//     let samplePage: BirdWikiPage;
//     let helperFunctions: BirdHelperFunctions;
//     let stageDataMock: Stub;
//     let summariseDescription: Stub;

//     beforeAll(() => {
//         let createClientStub = stub(SupabaseFunctions, "createClient", () => { return {}; });
//         helperFunctions = new BirdHelperFunctions("a", "0.1")
//         summariseDescription = stub(helperFunctions, "summariseDescription", async () => { return "TEST CONTENT DESCRIPTION"})
//         stageDataMock = stub(_functions, "stageData");
//         samplePage = new BirdWikiPage();
//     })

//     beforeEach(async () => {
//         sampleHtml = (await Deno.readTextFile(path+"mockHTML.html")).trim();
//         samplePage.birdName = "TestBird";
//         samplePage.birdScientificName = "TestScientificName     ";
//         samplePage.birdFamily = "TestFamily";
//         samplePage.birdDescription = "TEST CONTENT DESCRIPTION TEST CONTENT DESCRIPTION \n" + "TEST CONTENT DESCRIPTION";
//         samplePage.birdDiet = "TEST CONTENT DIET";
//         samplePage.birdSummary = "TEST CONTENT SUMMARY TEST CONTENT SUMMARY"
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml; });
//         fakeUrl = new URL( "http://localhost?parms=test");
//     })

//     afterEach(() => {
//         fetchTextMock.restore();
//     })

//     afterAll(() => {

//     })

//     it("should call fetchText with speciesUrl", async () => {
//         await parseWikiPage(fakeUrl, helperFunctions);
//         assertSpyCall(fetchTextMock, 0, {
//             args: [fakeUrl]
//         })
//     })

//     it("should call stageData with sample page", async () => {
//         await parseWikiPage(fakeUrl, helperFunctions);
//         assertSpyCall(stageDataMock, 0, {
//             args: [samplePage]
//         });
//     })

//     it("should call stageData with sample page when html has no headings", async () => {
//         fetchTextMock.restore();
//         sampleHtml = await Deno.readTextFile(path + "mockHTMLNoHeadings.html");
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
//         await parseWikiPage(fakeUrl, helperFunctions);
//         assertSpyCall(stageDataMock, 0, {
//             args: [samplePage]
//         });
//     })

//     it("should call summariseDescription if description is greater than 3500 characters",async () => {
//         fetchTextMock.restore();
//         sampleHtml = await Deno.readTextFile(path + "mockHTMLLargeDescription.html");
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
//         await parseWikiPage(fakeUrl, helperFunctions);
//         assertSpyCall(summariseDescription, 0, {});
//     })

//     it("should call summariseDescription if no heading page content is greater than 3500 characters",async () => {
//         fetchTextMock.restore();
//         sampleHtml = await Deno.readTextFile(path + "mockHTMLNoHeadingsLD.html");
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
//         await parseWikiPage(fakeUrl, helperFunctions);
//         assertSpyCall(summariseDescription, 0, {});
//     })


//     it("should return 501 when fetchText returns nothing", async () => {
//         fetchTextMock.restore();
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return ""});
//         const result: Response = await parseWikiPage(fakeUrl, helperFunctions);
//         assertEquals(result.status, 501);
//     })

//     it("should return 501 when it fails to find the family name", async () => {
//         fetchTextMock.restore();
//         sampleHtml = await Deno.readTextFile(path + "mockMissingFamilyName.html");
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
//         const result: Response = await parseWikiPage(fakeUrl, helperFunctions);
//         assertEquals(result.status, 501);
//         assertEquals(await result.json(), { error: "Unable to find family name" });
//     })

//     it("should return 501 when it fails to find the scientific name", async () => {
//         fetchTextMock.restore();
//         sampleHtml = await Deno.readTextFile(path + "mockMissingScientificName.html");
//         fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
//         const result: Response = await parseWikiPage(fakeUrl, helperFunctions);
//         assertEquals(result.status, 501);
//         assertEquals(await result.json(), { error: "Unable to find scientific name" });
//     })
// });