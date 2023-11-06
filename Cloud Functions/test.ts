import { OpenAI } from "https://esm.sh/openai@4.11.1";
import { load } from "https://deno.land/std@0.202.0/dotenv/mod.ts";

const env = await load();
const OPENAI_API_KEY = env["OPENAI_API_KEY"];

const openai = new OpenAI({
    apiKey: OPENAI_API_KEY,
});

function getCurrentWeather(location:string, units:string):string {
    return JSON.stringify({
        location: location,
        temperature: 27,
        unit: units,
        forecast: ["sunny", "windy"]
    });
}

async function main() {
    const message:any[] = [{ role: 'user', content: 'What\'s the weather like in Boston?' }];
    const functions = [
        {
            "name": "getCurrentWeather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
        }
    ]

    const chatCompletion = await openai.chat.completions.create({
      messages: message,
      functions: functions,
      function_call: "auto",
      model: 'gpt-3.5-turbo',
    });
  
    const response = chatCompletion.choices[0].message;

    if(response.function_call) {
        const functionName:string = response.function_call.name as string;
        if(functionName == "getCurrentWeather") {
            const functionArgs = response.function_call.arguments;
            const result = getCurrentWeather(functionArgs[0], functionArgs[1]);
            message.push(response);
            message.push({
                role: "function",
                name: functionName,
                content: result
            })

            const secondResult = await openai.chat.completions.create({
                messages: message,
                model: 'gpt-3.5-turbo',
            })
            console.log(secondResult);
        }
    }
    else {
        console.log(response.content)
    }
}
  
  main();