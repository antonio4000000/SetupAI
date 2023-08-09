/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-08
 * Description: Test coverage for Function.cls
*/

@isTest
public with sharing class TestFunction {
    
    @testSetup
    static void testSetup(){
        Callout.testSetup = true;
        Account testAccount = new Account(Name = 'Test Account',
                                          AccountNumber = '1234');
        insert testAccount;
        Chat__c testChat = TestDataFactory.getChat('Query Account');
        insert testChat;
        //Insert dummy messages
        Message__c[] thread = new Message__c[]{
            new Message__c(
                Role__c = 'system',
                Content__c = 'Execute SOQL query "SELECT AccountNumber FROM Account WHERE Name = \'Test Account\'',
                Thread__c = testChat.Id
            ),
            new Message__c(
                Role__c = 'user',
                Content__c = 'What is the Account number of the account named \'Test Account\'?',
                Thread__c = testChat.Id
            )
        };
        insert thread;
    }

    //Test SOQL query function call
    @isTest
    static void testSoql(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'assistant',
            Function_Name__c = 'soql',
            Function_Arguments__c = '{"type":"data","query":"SELECT AccountNumber FROM Account WHERE Name = \'Test Account\'"}',
            Thread__c = testChat.Id
        );
        Test.stopTest();
        
        //Verify results
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
                                 System.debug(messages);
        System.assertEquals(5, messages.size(), 'Unexpected number of messages');
        System.assertEquals('soql', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('soql', messages[3].Function_Name__c, 'Unexpected function call');
        System.assert(messages[3].Content__c.contains('"1234"'), 'Unexpected function content');
        System.assertEquals('assistant', messages[4].Role__c, 'Unexpected role on message');
        System.assertEquals('The Account number of the account named \'Test Account\' is 1234.', messages[4].Content__c, 'Unexpected content from assistant');
    }

}