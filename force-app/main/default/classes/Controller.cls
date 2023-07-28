/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-21
 * Description: Controller for LWC user interface for chat
*/

public with sharing class Controller {

    //--------------Chat Initialization Methods and Variables------->>>>>>>>>>

    private static final String TITLE_LABEL = 'Title';
    private static final String HELPER_LABEL = 'Helper';
    private static final String PRIMARY_LABEL = 'Primary';

    //Saves user message to Salesforce
    @AuraEnabled
    public static void submitMessage(String content, String chatId){
        try {
            if(chatId == null){
                initialize(content);
            }else{
                insert new Message__c(Thread__c = chatId,
                                      Content__c = content,
                                      Role__c = 'user');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Creates Chat and System message before inserting first chat message
    private static void initialize(String firstMessage){
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

    //<<<<<<<<<<----Chat Initialization Methods and Variables-----------------

    //--------------Message Retrieval Methods and Variables--------->>>>>>>>>>

    //Retrieves messages on a given chat thread
    @AuraEnabled
    public static MessageWrapper[] getMessages(String chatId){
        try {
            MessageWrapper[] toReturn = new MessageWrapper[]{};
            Message__c[] msgObj = [SELECT Content__c, Role__c 
                                   FROM Message__c 
                                   WHERE Thread__c = :chatId 
                                   AND Function_Name__c = null 
                                   AND Role__c != 'function'
                                   ORDER BY CreatedDate ASC];
            for(Message__c msg : msgObj){
                MessageWrapper returnObj = new MessageWrapper();
                if(msg.Role__c == 'user'){
                    returnObj.containerClass = 'slds-chat-listitem slds-chat-listitem_outbound';
                    returnObj.msgClass = 'slds-chat-message__text slds-chat-message__text_outbound';
                    returnObj.id = msg.Id;
                    returnObj.text = msg.Content__c;
                }
                if(msg.Role__c == 'assistant' || msg.Role__c == 'error'){
                    returnObj.msgClass = 'slds-chat-message__text slds-chat-message__text_inbound';
                    returnObj.containerClass = 'slds-chat-listitem slds-chat-listitem_inbound';
                    returnObj.id = msg.Id;
                    returnObj.text = (msg.Role__c == 'error' ? 'ERROR: ' : '' ) + msg.Content__c;
                }
                if(returnObj.text != null){
                    toReturn.add(returnObj);
                }
            }
            return toReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Wrapper for messages to return
    public class MessageWrapper {
        @AuraEnabled
        public string id{get;set;}
        @AuraEnabled
        public string text{get;set;}
        @AuraEnabled
        public string msgClass{get;set;}
        @AuraEnabled
        public string containerClass{get;set;}
    }


}