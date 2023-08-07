/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-07
 * Description: Test coverage for Controller.cls
*/

@isTest
public with sharing class TestController {
    
    @testSetup
    static void testSetup(){
        Callout.testSetup = true;
        Chat__c testChat = TestDataFactory.createCompleteChat();
    }

    @isTest
    static void testGetMessages(){
        //Get test chat
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        Controller.MessageWrapper[] messages = Controller.getMessages(testChat.Id);
        System.debug(messages);
        Test.stopTest();
        
        //Verify results
        System.assertEquals(2, messages.size(), 'Incorect number of messages');
        System.assertEquals(Controller.OUTBOUND_MESSAGE_CLASS, messages[0].msgClass, 'Incorrect class');
        System.assertEquals(Controller.OUTBOUND_CONTAINER_CLASS, messages[0].containerClass, 'Incorrect class');
        System.assertEquals('What is the api name of the Chat object?', messages[0].text, 'Incorrect message');
        System.assertEquals(Controller.INBOUND_MESSAGE_CLASS, messages[1].msgClass, 'Incorrect class');
        System.assertEquals(Controller.INBOUND_CONTAINER_CLASS, messages[1].containerClass, 'Incorrect class');
        System.assertEquals('The API name of the Chat object is "SetupAI__Chat__c".', messages[1].text, 'Incorrect message');
    }

    @isTest
    static void testGetChatSummary(){
        //Get test chat
        Chat__c testChat = [SELECT Id, Name
                            FROM Chat__c
                            LIMIT 1];

        //Run test
        Test.startTest();
        String chatName = Controller.getChatSummary(testChat.Id);
        Test.stopTest();

        //Verify results
        System.assertEquals(testChat.Name, chatName, 'Unexpected Chat Summary');
    }

    @isTest 
    static void testSubmitMessageNew(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());

        //Run test
        Test.startTest();
        String results = Controller.submitMessage('Hi there', null);
        Test.stopTest();

        //Verify results
        Chat__c newChat = [SELECT Id, Name 
                           FROM Chat__c
                           WHERE Id = :results];
        System.assertEquals('Chat thread started', newChat.Name, 'Unexpected thread summary');
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :newChat.Id
                                 ORDER BY Id];
        System.assertEquals(3, messages.size(), 'Unexpected number of messages saved to chat');
        System.assertEquals('system', messages[0].Role__c, 'Unexpected role on message');
        System.assert(messages[0].Content__c.contains('Just say hi and ask the end user how you can help them today'), 'Unexpected content in system message');
        System.assertEquals('user', messages[1].Role__c, 'Unexpected role on message');
        System.assertEquals('Hi there', messages[1].Content__c, 'Unexpected user message content');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('Hello! How can I help you today?', messages[2].Content__c, 'Unexpected user message content');
    }

    @isTest
    static void testSubmitMessageExisting(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        String results = Controller.submitMessage('Thank you very much', testChat.Id);
        Test.stopTest();

        //Verify results
        Message__c[] allMessages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                    FROM SetupAI__Message__c 
                                    WHERE SetupAI__Thread__c = :testChat.Id
                                    ORDER BY Id];
        System.assertEquals(7, allMessages.size(), 'Unexpected number of messages saved to thread');
        System.assertEquals('user', allMessages[5].Role__c, 'Unexpected role for message');
        System.assertEquals('Thank you very much', allMessages[5].Content__c, 'Unexpected content on user message');
        System.assertEquals('assistant', allMessages[6].Role__c, 'Unexpected role for message');
        System.assertEquals('You\'re welcome! If you have any more questions, feel free to ask.', allMessages[6].Content__c, 'Unexpected content on assistant message');
    }

}