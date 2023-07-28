/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-21
 * Description: Controller for LWC user interface for chat
*/

public with sharing class Controller {

    private static final String TITLE_LABEL = 'Title';
    private static final String HELPER_LABEL = 'Helper';
    private static final String PRIMARY_LABEL = 'Primary';
    
    //Creates Chat and System message before inserting first chat message
    @AuraEnabled(cacheable=true)
    public static void initialize(String firstMessage){
        Chat__c chat = generateChat(firstMessage);
        String systemPrompt = generateSystemPrompt(firstMessage);
        Message__c[] threadToInsert = new Message__c[]{
            new Message__c(
                Role__c = 'system',
                Content__c = [SELECT Content__c
                            FROM System_Prompt__mdt
                            WHERE MasterLabel = :PRIMARY_LABEL].Content__c + '\n' + systemPrompt
            ),
            new Message__c(
                Role__c = 'user',
                Content__c = firstMessage
            )
        };
        //Insert all records
        insert chat;
        for(Message__c message : threadToInsert){
            message.Thread__c = chat.Id;
        }
        insert threadToInsert;
    }

    //Creates initial Chat__c record
    private static Chat__c generateChat(String message){
        //Submit request to generate header
        String header = ChatInterface.chat(
            new ChatRequest.ChatMessage[]{
                //System prompt
                new ChatRequest.ChatMessage(
                    'system',
                    [SELECT Content__c
                     FROM System_Prompt__mdt
                     WHERE MasterLabel = :TITLE_LABEL].Content__c
                ),
                //User Prompt
                new ChatRequest.ChatMessage(
                    'user',
                    message
                )
            }, 
            'gpt-3',
            false
        ).content;
        //Save chat record
        return new Chat__c(
            Running__c = true,
            Name = header
        );
    }

    //Use gpt-4 to generate System prompt for gpt-3
    private static String generateSystemPrompt(String message){
        //Submit request to generate System prompt
        return ChatInterface.chat(
            new ChatRequest.ChatMessage[]{
                //System prompt for this request
                new ChatRequest.ChatMessage(
                    'system',
                    [SELECT Content__c
                    FROM System_Prompt__mdt
                    WHERE MasterLabel = :HELPER_LABEL].Content__c
                ),
                //User Prompt
                new ChatRequest.ChatMessage(
                    'user',
                    message
                )
            }, 
            'gpt-4',
            false
        ).content;
    }

}