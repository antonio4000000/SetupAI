/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interfaces Salesforce objects with OpenAIs chat API
*/

public with sharing class ChatInterface {

    //Get Model name for given abbreviation
    private static String getModel(String modelAbbr){
        return [SELECT MasterLabel 
                FROM Model__mdt
                WHERE Abbreviation__c = :modelAbbr
                WITH SECURITY_ENFORCED].MasterLabel;
    }

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
            /** model */            getModel(model == null ? 'gpt-3' : model),
            /** temperature */      0,
            /** messages */         messages,
            /** functions */        includeFunctions ? getFunctions() : null
        );
        //Submit request
        ChatResponse res = OpenAI.chat(req);
        if(res?.usage?.total_tokens != null){ Tokenizer.updateUsage(res.usage.total_tokens); }
        //Return response from assistant
        ChatRequest.ChatMessage toReturn = res?.choices[0]?.message;
        if(toReturn != null){
            //Copy tokens down so they can be saved to records later
            toReturn.completionTokens = res?.usage?.completion_tokens;
            toReturn.promptTokens = res?.usage?.prompt_tokens;
        }
        return toReturn;
    }

}