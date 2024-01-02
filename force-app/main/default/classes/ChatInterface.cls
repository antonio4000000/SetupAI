/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interfaces Salesforce objects with OpenAIs chat API
*/

public with sharing class ChatInterface {

    //Retrieve defined functions and return them formatted
    private static ChatRequest.ChatFunction[] getFunctions(){
        ChatRequest.ChatFunction[] toReturn = new ChatRequest.ChatFunction[]{};
        for(Function__mdt func : [SELECT Id, MasterLabel, Description__c,
                                    (SELECT Id, MasterLabel, Description__c, Type__c, Enumerated_Values__c, Required__c
                                     FROM Properties__r)
                                  FROM Function__mdt
                                  WITH SECURITY_ENFORCED]){
            toReturn.add(new ChatRequest.ChatFunction(func));
        }
        return toReturn;
    }

    //Submits Chat to API and returns response
    public static ChatRequest.ChatMessage chat(ChatRequest.ChatMessage[] messages, String model, Boolean includeFunctions){
        //Construct request
        ChatRequest req = new ChatRequest(
            /** model */            model,
            /** temperature */      0,
            /** messages */         messages,
            /** functions */        includeFunctions ? getFunctions() : null
        );
        //Submit request
        ChatResponse res = OpenAI.chat(req);
        Tokenizer.updateUsage(
            res?.usage?.prompt_tokens != null ? res.usage.prompt_tokens : 0,
            res?.usage?.completion_tokens != null ? res.usage.completion_tokens : 0
        );
        //Return response from assistant
        ChatRequest.ChatMessage toReturn = res?.choices != null && res?.choices.size() > 0 ?
                                           res?.choices[0]?.message :
                                           OpenAI.getError('Invalid response from server').choices[0].message;
        if(toReturn != null){
            //Copy tokens down so they can be saved to records later
            toReturn.completionTokens = res?.usage?.completion_tokens;
            toReturn.promptTokens = res?.usage?.prompt_tokens;
        }
        return toReturn;
    }

}