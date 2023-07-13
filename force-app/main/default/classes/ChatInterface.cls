/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interfaces Salesforce objects with OpenAIs chat API
*/

public with sharing class ChatInterface {

    //Get Model name for given abbreviation
    private static String getModel(String modelAbbr){
        return [SELECT MasterLabel 
                FROM SetupAI__Model__mdt
                WHERE SetupAI__Abbreviation__c = :modelAbbr].MasterLabel;
    }

    //Retrieve defined functions and return them formatted
    private static ChatRequest.ChatFunction[] getFunctions(){
        ChatRequest.ChatFunction[] toReturn = new ChatRequest.ChatFunction[]{};
        for(Function__mdt func : [SELECT Id, MasterLabel, Description__c,
                                                (SELECT Id, MasterLabel, Description__c, Type__c, Enumerated_Values__c, Required__c
                                                FROM Properties__r)
                                            FROM Function__mdt]){
            toReturn.add(new ChatRequest.ChatFunction(func));
        }
        return toReturn;
    }

    //Submits Chat to API and returns response
    public static ChatRequest.ChatMessage chat(ChatRequest.ChatMessage[] messages, String model){
        //Construct request
        ChatRequest req = new ChatRequest(
            getModel(model == null ? 'gpt-3' : model),
            0,
            messages,
            getFunctions()
        );
        //Submit request
        ChatResponse res = OpenAI.chat(req);
        //Return response from assistant
        return res?.choices[0]?.message;
    }
  

}