import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
import { assert } from "node:console";
// @deno-types="npm:@types/sinon"
import sinon, { SinonSpy, SinonStub } from "npm:sinon";
import { BirdShape, Supabase } from "../../supabase/functions/SupabaseClient.ts";
import { ChatGPT, GPTModels, OpenAIRequest, OpenAIRequestDirector } from "../../supabase/functions/OpenAIClient.ts";
import { ImageGenerator } from "../../supabase/functions/findSpecies/ImageGenerator.ts";
import { assertThrows } from "https://deno.land/std@0.214.0/assert/assert_throws.ts";
import OpenAI from "https://deno.land/x/openai@v4.16.1/mod.ts";
import Sinon from "npm:@types/sinon";

describe("ChatGPT", () => {
    const checkIfBirdAppearanceUnisexTests = describe("checkIfBirdAppearanceUnisex");

    const fakeEnvGet = sinon.fake.returns("OPEN-AI-API-KEY");
    const fakeChatGPTResponse: object =  {
        choices: [
            {
                message: {
                    content: "True"
                }
            }
        ]
    };
    const fakeDescription = "Fake description";

    let chatGPT: ChatGPT;
    let createStub: SinonStub;
    let buildGPT3requestSpy: SinonSpy;

    beforeEach(() => {
        sinon.createStubInstance(OpenAI);
        sinon.stub(OpenAIRequestDirector.prototype, "setSystemMessage");
        buildGPT3requestSpy = sinon.spy(OpenAIRequestDirector.prototype, "buildGPT3request");
        createStub = sinon.stub(OpenAI.Chat.Completions.prototype, "create")
        createStub.resolves(fakeChatGPTResponse);

        sinon.stub(Deno.env, "get").callsFake(fakeEnvGet);
        chatGPT = ChatGPT.instantiate();
    })

    afterEach(() => {
        sinon.restore();
    })

    it(checkIfBirdAppearanceUnisexTests, "should make build request with description", async () =>{
        await chatGPT.checkIfBirdAppearanceUnisex(fakeDescription);
        assert(buildGPT3requestSpy.calledWith(fakeDescription));
    })

    it(checkIfBirdAppearanceUnisexTests, "should return true if response content is \"True\"", async () => {
        const result = await chatGPT.checkIfBirdAppearanceUnisex("");
        assertEquals(result, true);
    })

    it(checkIfBirdAppearanceUnisexTests, "should return false if reponse content is \"False\"", async () => {
        const fakeFalseResponse = fakeChatGPTResponse as any;
        fakeFalseResponse.choices[0].message.content = "False";
        createStub.resolves(fakeFalseResponse);
        const result = await chatGPT.checkIfBirdAppearanceUnisex("");
        assertEquals(result, false);
    })

    it(checkIfBirdAppearanceUnisexTests, "should throw error if message content is null", async () => {
        const fakeFalseResponse = fakeChatGPTResponse as any;
        const errorMessage = "ChatGPT: There was an error with chatGPT and the bird appearance";
        fakeFalseResponse.choices[0].message.content = null;
        createStub.resolves(fakeFalseResponse);
        chatGPT.checkIfBirdAppearanceUnisex("").catch((error: Error) => {
            assertEquals(error.message, errorMessage);
        });
    })
})