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

    //Submits Chat to API and returns response
    public static ChatRequest.ChatMessage chat(ChatRequest.ChatMessage[] messages, String model){
        //Construct request
        ChatRequest req = new ChatRequest(
            getModel(model),
            0,
            messages,
            null //TODO: Functions
        );
        //Submit request
        ChatResponse res = OpenAI.chat(req);
        //Return response from assistant
        return res?.choices[0]?.message;
    }
  

}