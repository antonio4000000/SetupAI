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
        //Insert test Account
        Account testAccount = new Account(Name = 'Test Account',
                                          AccountNumber = '1234');
        insert testAccount;

        //Prep SOQL
        Chat__c soqlChat = TestDataFactory.getChat('Query Account');
        insert soqlChat;
        insert new Message__c[]{
            new Message__c(
                Role__c = 'system',
                Content__c = 'Execute SOQL query "SELECT AccountNumber FROM Account WHERE Name = \'Test Account\'',
                Thread__c = soqlChat.Id
            ),
            new Message__c(
                Role__c = 'user',
                Content__c = 'What is the Account number of the account named \'Test Account\'?',
                Thread__c = soqlChat.Id
            )
        };

        //Prep Tooling
        Chat__c toolingChat = TestDataFactory.getChat('MessageTriggerHandler Apex Class Summary');
        insert toolingChat;
        insert new Message__c[]{
            new Message__c(
                Role__c = 'system',
                Content__c = '1. Retrieve the MessageTriggerHandler Apex class:- This will allow you to read the class and summarize its contents for the user.- Run this Tooling API SOQL query "SELECT Name, Body FROM ApexClass WHERE Name = \'MessageTriggerHandler\'"- If a result is returned, assess the class body contents. Look for the methods and their functionality, the variables and their usage, and any patterns or best practices followed. Summarize these findings for the user. If there are any best practices not followed or errors, make some simple recommendations they could do to fix the class or make it more efficient.- If no class was found, re-run the query but with this where clause: "WHERE Name LIKE \'%MessageTriggerHandler%\'". If you find a class with a name just 1-2 characters off from MessageTriggerHandler, summarize that class for the user following the guidelines in the previous step.- If still no class is found, let the user know you couldn\'t find the class they were referring to, and ask them to double check the exact name of the class.',
                Thread__c = toolingChat.Id
            ),
            new Message__c(
                Role__c = 'user',
                Content__c = 'Summarize the MessageTriggerHandler Apex class',
                Thread__c = toolingChat.Id
            )
        };
    }

    //Test SOQL query function call
    @isTest
    static void testSoql(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'Query Account'
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
        System.assertEquals(5, messages.size(), 'Unexpected number of messages');
        System.assertEquals('soql', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('soql', messages[3].Function_Name__c, 'Unexpected function call');
        System.assert(messages[3].Content__c.contains('"1234"'), 'Unexpected function content');
        System.assertEquals('assistant', messages[4].Role__c, 'Unexpected role on message');
        System.assertEquals('The Account number of the account named \'Test Account\' is 1234.', messages[4].Content__c, 'Unexpected content from assistant');
    }

    //Test Tooling SOQL function call
    @isTest
    static void testToolingSOQL(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'MessageTriggerHandler Apex Class Summary'
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'assistant',
            Function_Name__c = 'soql',
            Function_Arguments__c = '{"type":"tooling","query":"SELECT Name, Body FROM ApexClass WHERE Name = \'MessageTriggerHandler\'"}',
            Thread__c = testChat.Id
        );
        Test.stopTest();
        
        //Verify results
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
        System.assertEquals(5, messages.size(), 'Unexpected number of messages');
        System.assertEquals('soql', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('soql', messages[3].Function_Name__c, 'Unexpected function call');
        System.assert(messages[3].Content__c.contains('public with sharing class MessageTriggerHandler'), 'Unexpected function content');
        System.assertEquals('assistant', messages[4].Role__c, 'Unexpected role on message');
        System.assert(messages[4].Content__c.contains('The MessageTriggerHandler Apex class is a public class that implements the Queueable and Database.AllowsCallouts interfaces'), 'Unexpected assistant content');
    }

}