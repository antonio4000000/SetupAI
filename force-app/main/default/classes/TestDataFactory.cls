/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-07
 * Description: Generate Test Data for test classes
*/

@isTest
public with sharing class TestDataFactory {

    //Create User to run code as
    public static User createTestUser(){
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = :'System Administrator'];
        User testUser = new User(
            FirstName = 'SetupAI',
            LastName = 'User',
            Alias = 'setup',
            Email = 'setupai-user' + Utils.getRandom() + '@setupai.com',
            Username = 'setupai-user' + Utils.getRandom() + '@setupai.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdmin.Id,
            TimeZoneSidKey = 'America/Chicago'
        );
        insert testUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SetupAI'];
        insert new PermissionSetAssignment(
            AssigneeId = testUser.id, 
            PermissionSetId = ps.Id
        );
        return testUser;
    }
    
    //Generate Chat__c record along with related Message__c records
    public static Chat__c createCompleteChat(){
        Chat__c newChat = getChat('Chat object API name request');
        insert newChat;
        insert getMessages(newChat.Id);
        return newChat;
    }

    //Create a Chat__c with System messaqe and user message
    public static Chat__c createChatWithFirstMessage(String summary, String userMessage){
        Chat__c newChat = TestDataFactory.getChat(summary);
        insert newChat;
        insert new Message__c[]{
            new Message__c(
                Role__c = 'user',
                Content__c = userMessage,
                Thread__c = newChat.Id
            )
        };
        return newChat;
    }

    //Generate single Chat__c record
    public static Chat__c getChat(String summary){
        return new Chat__c(
            Name = summary,
            Running__c = true
        );
    }

    //Generate messages to save to chat 
    public static Message__c[] getMessages(Id chatId){
        return new Message__c[]{
            getMessage(chatId, 'user', 'What is the api name of the Chat object?', null, null),
            getMessage(chatId, 'assistant', null, 'soql', '{  "query": "SELECT Id, QualifiedAPIName FROM EntityDefinition WHERE MasterLabel = \'Chat\'"}'),
            getMessage(chatId, 'function', '[{"attributes":{"type":"EntityDefinition","url":"/services/data/v58.0/sobjects/EntityDefinition/01I03000000qaL6"},"Id":"000000000000000AAA","QualifiedApiName":"Chat__c","DurableId":"01I03000000qaL6"}]', 'soql', null),
            getMessage(chatId, 'assistant', 'The API name of the Chat object is "Chat__c".', null, null)
        };
    }

    //Generate Message__c record
    public static Message__c getMessage(Id chatId, String role, String content, String functionName, String functionArguments){
        return new Message__c(
            Thread__c = chatId,
            Role__c = role,
            Content__c = content,
            Function_Name__c = functionName,
            Function_Arguments__c = functionArguments
        );
    }

}