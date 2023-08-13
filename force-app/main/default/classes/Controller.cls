/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-21
 * Description: Controller for LWC user interface for chat
*/

public with sharing class Controller {

    public static final String OUTBOUND_MESSAGE_CLASS = 'slds-chat-message__text slds-chat-message__text_outbound-agent';
    public static final String OUTBOUND_CONTAINER_CLASS = 'slds-chat-listitem slds-chat-listitem_outbound';
    public static final String INBOUND_MESSAGE_CLASS = 'slds-chat-message__text slds-chat-message__text_inbound';
    public static final String INBOUND_CONTAINER_CLASS = 'slds-chat-listitem slds-chat-listitem_inbound';

    //--------------Chat Initialization Methods and Variables------->>>>>>>>>>

    //Saves user message to Salesforce
    @AuraEnabled
    public static String submitMessage(String content, String chatId){
        try {
            //Verify access to messages and chat
            if(CRUD.createChat() && CRUD.createMessage()){
                if(chatId == null){
                    return initialize(content);
                }else{
                    insert new SetupAI__Message__c(SetupAI__Thread__c = chatId,
                                                   SetupAI__Content__c = content,
                                                   SetupAI__Role__c = 'user');
                    return null;
                }
            }else{
                throw new AuraHandledException(Label.Create_Chat_Access);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Creates Chat and System message before inserting first chat message
    private static String initialize(String firstMessage){
        SetupAI__Chat__c chat = generateChat(firstMessage);
        insert chat;
        insert new SetupAI__Message__c(
            SetupAI__Role__c = 'user',
            SetupAI__Content__c = firstMessage,
            SetupAI__Thread__c = chat.Id
        );
        return chat.Id;
    }

    //Creates initial Chat__c record
    private static SetupAI__Chat__c generateChat(String message){
        //Submit request to generate header
        String header = ChatInterface.chat(
            new ChatRequest.ChatMessage[]{
                //System prompt
                new ChatRequest.ChatMessage(
                    'system',
                    SystemPromptHelper.getPrompt(SystemPromptHelper.TITLE_LABEL)
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
        return new SetupAI__Chat__c(
            SetupAI__Running__c = true,
            Name = header
        );
    }

    //<<<<<<<<<<----Chat Initialization Methods and Variables-----------------

    //--------------Message Retrieval Methods and Variables--------->>>>>>>>>>

    //Retrieves messages on a given chat thread
    @AuraEnabled
    public static MessageWrapper[] getMessages(String chatId){
        try {
            MessageWrapper[] toReturn = new MessageWrapper[]{};
            Message__c[] msgObj = [SELECT SetupAI__Content__c, SetupAI__Role__c 
                                   FROM SetupAI__Message__c 
                                   WHERE SetupAI__Thread__c = :chatId 
                                   AND SetupAI__Function_Name__c = null 
                                   AND SetupAI__Role__c != 'function'
                                   AND SetupAI__Role__c != 'system'
                                   WITH SECURITY_ENFORCED
                                   ORDER BY CreatedDate ASC];
            for(Message__c msg : msgObj){
                MessageWrapper returnObj = new MessageWrapper();
                if(msg.SetupAI__Role__c == 'user'){
                    returnObj.containerClass = OUTBOUND_CONTAINER_CLASS;
                    returnObj.msgClass = OUTBOUND_MESSAGE_CLASS;
                    returnObj.id = msg.Id;
                    returnObj.text = msg.SetupAI__Content__c;
                }
                if(msg.SetupAI__Role__c == 'assistant' || msg.SetupAI__Role__c == 'error'){
                    returnObj.containerClass = INBOUND_CONTAINER_CLASS;
                    returnObj.msgClass = INBOUND_MESSAGE_CLASS;
                    returnObj.id = msg.Id;
                    returnObj.text = (msg.SetupAI__Role__c == 'error' ? 'ERROR: ' : '' ) + msg.SetupAI__Content__c;
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

    //<<<<<<<<-------Message Retrieval Methods and Variables------------------

    @AuraEnabled
    public static String getChatSummary(String chatId){
        try {
            if(chatId != null){
                return [SELECT Name
                        FROM SetupAI__Chat__c
                        WHERE Id =: chatId
                        WITH SECURITY_ENFORCED].Name;
            }else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}