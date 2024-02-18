import { assertEquals } from "https://deno.land/std@0.214.0/assert/mod.ts";
import { afterAll, afterEach, beforeAll, beforeEach, describe, it} from "https://deno.land/std@0.207.0/testing/bdd.ts";
import { assert } from "node:console";
// @deno-types="npm:@types/sinon"
import sinon, { SinonSpy, SinonStub, SinonStubbedInstance } from "npm:sinon";
import { BirdShape, Supabase } from "../../supabase/functions/SupabaseClient.ts";
import { ChatGPT, GPTModels, OpenAIRequest, OpenAIRequestDirector } from "../../supabase/functions/OpenAIClient.ts";
import { ImageGenerator } from "../../supabase/functions/findSpecies/ImageGenerator.ts";
import { assertThrows } from "https://deno.land/std@0.214.0/assert/assert_throws.ts";
import OpenAI from "npm:openai";
import TestHelper from "../TestHelper.ts";

describe("ChatGPT", () => {
    const checkIfBirdAppearanceUnisexTests = describe("checkIfBirdAppearanceUnisex");

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

    let openAIStub: SinonStubbedInstance<OpenAI>;
    let openAIRequestDirectorStub: SinonStubbedInstance<OpenAIRequestDirector>;
    let createStub: SinonStub;
    let denoEnvStub: SinonStubbedInstance<Deno.Env>;
    
    let chatGPT: ChatGPT;
    
    beforeAll(() => {
        openAIStub = sinon.createStubInstance(OpenAI);
        openAIRequestDirectorStub = sinon.stub(OpenAIRequestDirector.prototype);
        createStub = sinon.stub(OpenAI.Chat.Completions.prototype, "create")
        denoEnvStub = TestHelper.createDenoEnvStub();
    })

    beforeEach(() => {
        createStub.resolves(fakeChatGPTResponse);

        TestHelper.setDenoEnvStub(denoEnvStub);
        chatGPT = ChatGPT.instantiate();
    })

    afterEach(() => {
        sinon.reset();
    })

    afterAll(() => {
        sinon.restore();
    });

    it(checkIfBirdAppearanceUnisexTests, "should make build request with description", async () =>{
        await chatGPT.checkIfBirdAppearanceUnisex(fakeDescription);
        assert(openAIRequestDirectorStub.buildGPT3request.calledWith(fakeDescription));
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