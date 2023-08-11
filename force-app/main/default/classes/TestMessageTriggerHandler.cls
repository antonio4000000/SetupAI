/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-08
 * Description: Test coverage for MessageTrigger.trigger and MessageTriggerHandler.cls
*/

@isTest
public with sharing class TestMessageTriggerHandler {
    
    @testSetup
    static void testSetup(){
        Callout.testSetup = true;
        //Inser dummy chat
        Chat__c testChat = TestDataFactory.getChat('Get User Id');
        insert testChat;
        //Insert dummy messages
        insert new Message__c(
            Role__c = 'user',
            Content__c = 'What is my user Id?',
            Thread__c = testChat.Id
        );
    }

    //Tests Assistant calling a function
    @isTest
    static void testAssistantFunctionCall(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'assistant',
            Function_Name__c = 'getUserId',
            Thread__c = testChat.Id
        );
        Test.stopTest();

        //Verify results
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
        System.assertEquals(4, messages.size(), 'Unexpected number of messages');
        System.assertEquals('getUserId', messages[1].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('getUserId', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals(UserInfo.getUserId(), messages[2].Content__c, 'Unexpected function content');
        System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('Your user Id is ' + UserInfo.getUserId() + '.', messages[3].Content__c, 'Unexpected content from assistant');
    }

    //Test Error message being inserted
    @isTest
    static void testErrorMessage(){
        //Setup test
        //Leave out setting mock so error is thrown
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'assistant',
            Function_Name__c = 'getUserId',
            Thread__c = testChat.Id
        );
        Test.stopTest();

        //Verify results
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
        System.assertEquals(4, messages.size(), 'Unexpected number of messages');
        System.assertEquals('getUserId', messages[1].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('getUserId', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals(UserInfo.getUserId(), messages[2].Content__c, 'Unexpected function content');
        System.assertEquals('error', messages[3].Role__c, 'Unexpected role on message');
        System.assert(messages[3].Content__c.contains('Methods defined as TestMethod do not support Web service callouts'), 'Unexpected error message');
    }

    @isTest
    static void testAsyncError(){
        //Setup test
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'HEY',
            Content__c = 'hey',
            Thread__c = testChat.Id
        );
        Test.stopTest();

        //Verify results
        System.assertEquals(1, MessageTriggerHandler.asyncErrorsPublished.size(), 'Incorrect number of events published');
        System.assertEquals(Label.Unexpected_Role, MessageTriggerHandler.asyncErrorsPublished[0].SetupAI__Error_Content__c, 'Unexpected Error Message');
        System.assertEquals(testChat.Id, MessageTriggerHandler.asyncErrorsPublished[0].Chat_Id__c, 'Unexpected Error Message');
    }

}