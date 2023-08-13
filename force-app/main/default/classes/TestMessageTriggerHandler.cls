/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-08
 * Description: Test coverage for MessageTrigger.trigger and MessageTriggerHandler.cls
*/

@isTest
public with sharing class TestMessageTriggerHandler {
    
    @testSetup
    static void testSetup(){
        User testUser = TestDataFactory.createTestUser();
        System.runAs(testUser){
            Callout.testSetup = true;
            //Inser dummy chat
            SetupAI__Chat__c testChat = TestDataFactory.getChat('Get User Id');
            insert testChat;
            //Insert dummy messages
            insert new SetupAI__Message__c(
                SetupAI__Role__c = 'user',
                SetupAI__Content__c = 'What is my user Id?',
                SetupAI__Thread__c = testChat.Id
            );
        }
    }

    //Tests Assistant calling a function
    @isTest
    static void testAssistantFunctionCall(){
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
        System.runAs(testUser){
            insert new SetupAI__Message__c(
                SetupAI__Role__c = 'assistant',
                SetupAI__Function_Name__c = 'getUserId',
                SetupAI__Thread__c = testChat.Id
            );
        }
        Test.stopTest();

        //Verify results
        SetupAI__Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                          FROM SetupAI__Message__c 
                                          WHERE SetupAI__Thread__c = :testChat.Id
                                          ORDER BY Id];
        System.assertEquals(4, messages.size(), 'Unexpected number of messages');
        System.assertEquals('getUserId', messages[1].SetupAI__Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[1].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[2].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('getUserId', messages[2].SetupAI__Function_Name__c, 'Unexpected function call');
        System.assertEquals(UserInfo.getUserId(), messages[2].SetupAI__Content__c, 'Unexpected function content');
        System.assertEquals('assistant', messages[3].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('Your user Id is ' + UserInfo.getUserId() + '.', messages[3].SetupAI__Content__c, 'Unexpected content from assistant');
    }

    //Test Error message being inserted
    @isTest
    static void testErrorMessage(){
        //Setup test
        //Leave out setting mock so error is thrown
        SetupAI__Chat__c testChat = [SELECT Id
                                     FROM SetupAI__Chat__c
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];

        //Run test
        Test.startTest();
        System.runAs(testUser){
            insert new SetupAI__Message__c(
                SetupAI__Role__c = 'assistant',
                SetupAI__Function_Name__c = 'getUserId',
                SetupAI__Thread__c = testChat.Id
            );
        }
        Test.stopTest();

        //Verify results
        SetupAI__Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                          FROM SetupAI__Message__c 
                                          WHERE SetupAI__Thread__c = :testChat.Id
                                          ORDER BY Id];
        System.assertEquals(4, messages.size(), 'Unexpected number of messages');
        System.assertEquals('getUserId', messages[1].SetupAI__Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[1].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[2].SetupAI__Role__c, 'Unexpected role on message');
        System.assertEquals('getUserId', messages[2].SetupAI__Function_Name__c, 'Unexpected function call');
        System.assertEquals(UserInfo.getUserId(), messages[2].SetupAI__Content__c, 'Unexpected function content');
        System.assertEquals('error', messages[3].SetupAI__Role__c, 'Unexpected role on message');
        System.assert(messages[3].SetupAI__Content__c.contains('Methods defined as TestMethod do not support Web service callouts'), 'Unexpected error message');
    }

    @isTest
    static void testAsyncError(){
        //Setup test
        SetupAI__Chat__c testChat = [SELECT Id
                                     FROM SetupAI__Chat__c
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];

        //Run test
        Test.startTest();
        System.runAs(testUser){
            insert new SetupAI__Message__c(
                SetupAI__Role__c = 'HEY',
                SetupAI__Content__c = 'hey',
                SetupAI__Thread__c = testChat.Id
            );
        }
        Test.stopTest();

        //Verify results
        System.assertEquals(1, MessageTriggerHandler.asyncErrorsPublished.size(), 'Incorrect number of events published');
        System.assertEquals(Label.Unexpected_Role, MessageTriggerHandler.asyncErrorsPublished[0].SetupAI__Error_Content__c, 'Unexpected Error Message');
        System.assertEquals(testChat.Id, MessageTriggerHandler.asyncErrorsPublished[0].SetupAI__Chat_Id__c, 'Unexpected Error Message');
    }

}