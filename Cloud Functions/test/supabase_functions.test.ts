import { assertEquals } from "https://deno.land/std@0.207.0/assert/mod.ts";
import { Stub, assertSpyCall, assertSpyCalls, spy, stub, } from "https://deno.land/std@0.207.0/testing/mock.ts";
import { parseWikiPage } from ".././supabase/functions/findSpecies/supabase_functions.ts";
import { BirdHelperFunctions, _webFunctions } from ".././supabase/functions/findSpecies/supabase_helper_functions.ts";
import { afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
import { DOMParser, HTMLDocument } from "https://deno.land/x/deno_dom/deno-dom-wasm.ts";

const mockHtmkDir = "/test/mockHtml/"
const path = Deno.cwd()+mockHtmkDir;


describe("parseWikiPage", () => {
    let fetchTextMock: Stub;
    let fakeUrl: URL;
    let sampleHtml: string;

    beforeEach(async () => {
        sampleHtml = await Deno.readTextFile(path+"mockHTML.html");
        fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
        fakeUrl = new URL( "http://localhost?parms=test");
    })

    afterEach(() => {
        fetchTextMock.restore();
    })

    it("should call fetchText with speciesUrl", async () => {
        await parseWikiPage(fakeUrl);
        assertSpyCall(fetchTextMock, 0, {
            args: [fakeUrl]
        })
    })

    it("should return 501 when fetchText returns nothing", async () => {
        fetchTextMock.restore();
        fetchTextMock = stub(_webFunctions, "fetchText", async () => { return ""});
        const result: Response = await parseWikiPage(fakeUrl);
        assertEquals(result.status, 501);
    })

    it("should return 501 when it fails to find the family name", async () => {
        fetchTextMock.restore();
        sampleHtml = await Deno.readTextFile(path + "mockMissingFamilyName.html");
        fetchTextMock = stub(_webFunctions, "fetchText", async () => { return sampleHtml});
        const result: Response = await parseWikiPage(fakeUrl);
        assertEquals(result.status, 501);
    })

    it("should return 501 when it fails to find the scientific name", async () => {
        const i = 0;
    })
});