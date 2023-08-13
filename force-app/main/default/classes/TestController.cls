/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-07
 * Description: Test coverage for Controller.cls
*/

@isTest
public with sharing class TestController {
    
    @testSetup
    static void testSetup(){
        User testUser = TestDataFactory.createTestUser();
        System.runAs(testUser){
            Callout.testSetup = true;
            Chat__c testChat = TestDataFactory.createCompleteChat();
        }
    }

    @isTest
    static void testGetMessages(){
        //Get test chat
        SetupAI__Chat__c testChat = [SELECT Id
                                     FROM SetupAI__Chat__c
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                         FROM User
                         WHERE FirstName = :'SetupAI'];
        
        //Run test
        Test.startTest();
        Controller.MessageWrapper[] messages;
        System.runAs(testUser){
            messages = Controller.getMessages(testChat.Id);
        }
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
        SetupAI__Chat__c testChat = [SELECT Id, Name
                                     FROM SetupAI__Chat__c
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];

        //Run test
        Test.startTest();
        String chatName;
        System.runAs(testUser){ 
            chatName = Controller.getChatSummary(testChat.Id);
        }
        Test.stopTest();

        //Verify results
        System.assertEquals(testChat.Name, chatName, 'Unexpected Chat Summary');
    }

    @isTest 
    static void testSubmitMessageNew(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];

        //Run test
        Test.startTest();
        String results;
        System.runAs(testUser){  
            results = Controller.submitMessage('Hi there', null);
        }
        Test.stopTest();

        //Verify results
        SetupAI__Chat__c newChat = [SELECT Id, Name 
                                    FROM SetupAI__Chat__c
                                    WHERE Id = :results];
        System.assertEquals('Chat thread started', newChat.Name, 'Unexpected thread summary');
        SetupAI__Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                          FROM SetupAI__Message__c 
                                          WHERE SetupAI__Thread__c = :newChat.Id
                                          ORDER BY Id];
        System.assertEquals(2, messages.size(), 'Unexpected number of messages saved to chat');
        System.assertEquals('user', messages[0].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('Hi there', messages[0].SetupAI__Content__c, 'Unexpected user message content');
        System.assertEquals('assistant', messages[1].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('Hello! How can I help you today?', messages[1].SetupAI__Content__c, 'Unexpected user message content');
    }

    @isTest
    static void testSubmitMessageExisting(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        SetupAI__Chat__c testChat = [SELECT Id
                                     FROM SetupAI__Chat__c
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        
        //Run test
        Test.startTest();
        String results;
        System.runAs(testUser){  
            results = Controller.submitMessage('Thank you very much', testChat.Id);
        }
        Test.stopTest();

        //Verify results
        SetupAI__Message__c[] allMessages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                             FROM SetupAI__Message__c 
                                             WHERE SetupAI__Thread__c = :testChat.Id
                                             ORDER BY Id];
        System.assertEquals(6, allMessages.size(), 'Unexpected number of messages saved to thread');
        System.assertEquals('user', allMessages[4].SetupAI__Role__c, 'Unexpected role for message');
        System.assertEquals('Thank you very much', allMessages[4].SetupAI__Content__c, 'Unexpected content on user message');
        System.assertEquals('assistant', allMessages[5].SetupAI__Role__c, 'Unexpected role for message');
        System.assertEquals('You\'re welcome! If you have any more questions, feel free to ask.', allMessages[5].SetupAI__Content__c, 'Unexpected content on assistant message');
    }

}