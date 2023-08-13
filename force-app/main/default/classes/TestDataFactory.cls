/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-07
 * Description: Generate Test Data for test classes
*/

@isTest
public with sharing class TestDataFactory {
    
    //Generate Chat__c record along with related Message__c records
    public static SetupAI__Chat__c createCompleteChat(){
        Chat__c newChat = getChat('Chat object API name request');
        insert newChat;
        insert getMessages(newChat.Id);
        return newChat;
    }

    //Create a Chat__c with System messaqe and user message
    public static SetupAI__Chat__c createChatWithFirstMessage(String summary, String userMessage){
        SetupAI__Chat__c newChat = TestDataFactory.getChat(summary);
        insert newChat;
        insert new SetupAI__Message__c[]{
            new SetupAI__Message__c(
                SetupAI__Role__c = 'user',
                SetupAI__Content__c = userMessage,
                SetupAI__Thread__c = newChat.Id
            )
        };
        return newChat;
    }

    //Generate single Chat__c record
    public static Chat__c getChat(String summary){
        return new SetupAI__Chat__c(
            Name = summary,
            SetupAI__Running__c = true
        );
    }

    //Generate messages to save to chat 
    public static SetupAI__Message__c[] getMessages(Id chatId){
        return new SetupAI__Message__c[]{
            getMessage(chatId, 'user', 'What is the api name of the Chat object?', null, null),
            getMessage(chatId, 'assistant', null, 'soql', '{  "query": "SELECT Id, QualifiedAPIName FROM EntityDefinition WHERE MasterLabel = \'Chat\'"}'),
            getMessage(chatId, 'function', '[{"attributes":{"type":"EntityDefinition","url":"/services/data/v58.0/sobjects/EntityDefinition/01I03000000qaL6"},"Id":"000000000000000AAA","QualifiedApiName":"SetupAI__Chat__c","DurableId":"01I03000000qaL6"}]', 'soql', null),
            getMessage(chatId, 'assistant', 'The API name of the Chat object is "SetupAI__Chat__c".', null, null)
        };
    }

    //Generate Message__c record
    public static SetupAI__Message__c getMessage(Id chatId, String role, String content, String functionName, String functionArguments){
        return new SetupAI__Message__c(
            SetupAI__Thread__c = chatId,
            SetupAI__Role__c = role,
            SetupAI__Content__c = content,
            SetupAI__Function_Name__c = functionName,
            SetupAI__Function_Arguments__c = functionArguments
        );
    }

}