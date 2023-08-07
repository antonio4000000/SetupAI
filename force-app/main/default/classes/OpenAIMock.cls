/* 
 * Author:     Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:    2023-08-07
 * Description:Mocking service for OpenAI callouts
*/

@isTest
public with sharing class OpenAIMock implements HttpCalloutMock {

    //------------------Map requests to responses-------------->>>>>>>>>>
    //User Request: 'Hi there'
    private static Map<String, String> hiThereResponseMap = new Map<String, String>{
        'LabelMaker'=>'{\n    "id":"chatcmpl-7l0t8GPIRPPNoOjIssgUZSQEKDjii",\n    "object":"chat.completion",\n    "created":1691439186,\n    "model":"gpt-3.5-turbo-0613",\n    "choices":[\n        {\n            "index":0,\n            "message":{\n                "role":"assistant",\n                "content":"Chat thread started"\n            },\n            "finish_reason":"stop"\n        }\n    ],\n    "usage":{\n        "prompt_tokens":84,\n        "completion_tokens":3,\n        "total_tokens":87\n    }\n}',
        'SystemPromptHelper'=>'{\n    "id":"chatcmpl-7l1LmtTSj59azb59hgLDIPJgR17kl",\n    "object":"chat.completion",\n    "created":1691440962,\n    "model":"gpt-4-0613",\n    "choices":[\n        {\n            "index":0,\n            "message":{\n                "role":"assistant",\n                "content":"Just say hi and ask the end user how you can help them today"\n            },\n            "finish_reason":"stop"\n        }\n    ],\n    "usage":{\n        "prompt_tokens":1834,\n        "completion_tokens":13,\n        "total_tokens":1847\n    }\n}',
        'Conversation'=>'{"id":"chatcmpl-7l1TcHKRVSXyTzSRQof2BvUDTLMoI","object":"chat.completion","created":1691441448,"model":"gpt-3.5-turbo-0613","choices":[{"index":0,"message":{"role":"assistant","content":"Hello! How can I help you today?"},"finish_reason":"stop"}],"usage":{"prompt_tokens":1122,"completion_tokens":10,"total_tokens":1132}}'
    };
    //User Request: 'Thank you very much'(continuing after info)
    private static Map<String, String> thankYouResponseMap = new Map<String, String>{
        'Conversation'=>'{"id": "chatcmpl-7l27kXhSQLd6DVel9iLGmxZ87JO3x","object": "chat.completion","created": 1691443936,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "You\'re welcome! If you have any more questions, feel free to ask."},"finish_reason": "stop"}],"usage": {"prompt_tokens": 1393,"completion_tokens": 17,"total_tokens": 1410}}'
    };

    //------------------Map requests to responses------------------------
    
    //Handle callout
    public HttpResponse respond(HttpRequest req){
        HttpResponse response = new HttpResponse();
        System.debug(req.getBody());
        response.setBody(
            getResponseBody(
                /* Request Body */      req.getBody(), 
                /* Mappings*/   req.getBody().contains('Hi there') ? hiThereResponseMap :
                                req.getBody().contains('Thank you very much') ? thankYouResponseMap : 
                                new Map<String, String>{}
            )
        );
        response.setStatusCode(200);
        response.setStatus('success');
        return response;
    }

    //Get response for a given request
    private static String getResponseBody(String body, Map<String, String> responseMap){
        return body.contains('You are a Salesforce chatbot label maker.') ? responseMap.get('LabelMaker') :
               body.contains('A Salesforce admin is asking another chatbot a question about their Salesforce org.') ? responseMap.get('SystemPromptHelper') :
               body.contains('"functions":') ? responseMap.get('Conversation') :
               null;
    }
    
    
}