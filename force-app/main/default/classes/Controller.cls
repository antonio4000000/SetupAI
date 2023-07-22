/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-21
 * Description: Controller for LWC user interface for chat
*/

public with sharing class Controller {
    
    //Creates Chat and System message before inserting first chat message
    @AuraEnabled(cacheable=true)
    public static void initialize(String firstMessage){
        //TODO:
        // - Create Chat record
        // - Call GPT-4 to generate system message
        // - Insert system message
        // - Insert first chat message
    }

    //Creates initial Chat__c record
    private static String generateChat(String message){
        //Submit request to generate header
        String header = ChatInterface.chat(
            new ChatRequest.ChatMessage[]{
                //System prompt
                new ChatRequest.ChatMessage(
                    'system',
                    [SELECT Content__c
                     FROM System_Prompt__mdt
                     WHERE MasterLabel = 'Title'].Content__c
                ),
                //User Prompt
                new ChatRequest.ChatMessage(
                    'user',
                    message
                )
            }, 
            'gpt-3'
        ).content;
        //Save chat record
        Chat__c newChat = new Chat__c(
            Running__c = true,
            Name = header
        );
        insert newChat;
        return newChat.Id;
    }

}