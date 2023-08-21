/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-08
 * Description: Test coverage for Function.cls
*/

@isTest
public with sharing class TestFunction {
    
    @testSetup
    static void testSetup(){
        User testUser = TestDataFactory.createTestUser();
        System.runAs(testUser){
            Callout.testSetup = true;
            //Insert test Account
            Account testAccount = new Account(Name = 'Test Account',
                                            AccountNumber = '1234');
            insert testAccount;
            //SOQL
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'Query Account',
                /** User */     'What is the Account number of the account named \'Test Account\'?'
            );
            //Tooling SOQL
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'MessageTriggerHandler Apex Class Summary',
                /** User */     'Summarize the MessageTriggerHandler Apex class'
            );
            //getToolingObjects
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'Accessible objects through Tooling API summary',
                /** User */     'What objects are accessible to me through the Tooling API?'
            );
            //getFields
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'Chat object fields summary',
                /** User */     'What fields are available on the Chat__c object?'
            );
            //getToolingFields
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'EntityDefinition Tooling API type fields summary',
                /** User */     'What fields are on the EntityDefinition Tooling API type?'
            );
            //metadataDrilldown
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  '\'Chat__c-Chat Layout\' page layout fields summary',
                /** User */     'What fields are on the \'Chat__c-Chat Layout\' page layout?'
            );
            //getURL
            TestDataFactory.createChatWithFirstMessage(
                /** Summary */  'URL retrieval request',
                /** User */     'What is my URL?'
            );
        }
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
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        System.runAs(testUser){
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
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                            FROM Message__c 
                                            WHERE Thread__c = :testChat.Id
                                            ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('soql', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('soql', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('"1234"'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assertEquals('The Account number of the account named \'Test Account\' is 1234.', messages[3].Content__c, 'Unexpected content from assistant');
        }
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
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        System.runAs(testUser){
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
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                            FROM Message__c 
                                            WHERE Thread__c = :testChat.Id
                                            ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('soql', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('soql', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('public with sharing class MessageTriggerHandler'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('The MessageTriggerHandler Apex class is a public class that implements the Queueable and Database.AllowsCallouts interfaces'), 'Unexpected assistant content');
        }
    }

    //Test getToolingObjects function call
    @isTest
    static void testGetToolingObjects(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                                     FROM Chat__c
                                     WHERE Name = :'Accessible objects through Tooling API summary'
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        
        System.runAs(testUser){
            //Run test
            Test.startTest();
            insert new Message__c(
                Role__c = 'assistant',
                Function_Name__c = 'getToolingObjects',
                Function_Arguments__c = '{}',
                Thread__c = testChat.Id
            );
            Test.stopTest();
            
            //Verify results
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                            FROM Message__c 
                                            WHERE Thread__c = :testChat.Id
                                            ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('getToolingObjects', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('getToolingObjects', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('["AIApplication","AIApplicationConfig","AIReplyRecommendationsSettings"'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('The objects accessible to you through the Tooling API are:  - AIApplication - AIApplicationConfig - AIReplyRecommendationsSettings - AccessControlPolicy - AccountInsightsSettings'), 'Unexpected assistant content');
        }
    }

    //Test getFields function call
    @isTest
    static void testGetFields(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'Chat object fields summary'
                            LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        
        System.runAs(testUser){
            //Run test
            Test.startTest();
            insert new Message__c(
                Role__c = 'assistant',
                Function_Name__c = 'getFields',
                Function_Arguments__c = '{"object_x": "SetupAI__Chat__c"}',
                Thread__c = testChat.Id
            );
            Test.stopTest();

            //Verify results
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                                FROM Message__c 
                                                WHERE Thread__c = :testChat.Id
                                                ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('getFields', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('getFields', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('[{"type":"ID","apiName":"Id",'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('The available fields on the Chat object (Chat__c) are:'), 'Unexpected assistant content');
        }
    }

    //Test getToolingFields function call
    @isTest
    static void testGetToolingFields(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'EntityDefinition Tooling API type fields summary'
                            LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        
        System.runAs(testUser){
            //Run test
            Test.startTest();
            insert new Message__c(
                Role__c = 'assistant',
                Function_Name__c = 'getToolingFields',
                Function_Arguments__c = '{"object_x": "EntityDefinition"}',
                Thread__c = testChat.Id
            );
            Test.stopTest();

            //Verify results
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                                FROM Message__c 
                                                WHERE Thread__c = :testChat.Id
                                                ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('getToolingFields', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('getToolingFields', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('[{"type":"id","apiName":"Id","label":"Entity Definition ID"},'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('The EntityDefinition Tooling API type has the following fields:  1. Id: Entity Definition ID 2. DurableId:'), 'Unexpected assistant content');
        }
    }

    //Test metadataDrilldown function call
    @isTest
    static void testMetadataDrilldown(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                                     FROM Chat__c
                                     WHERE Name = :'\'Chat__c-Chat Layout\' page layout fields summary'
                                     LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];
        
        System.runAs(testUser){
            //Run test
            Test.startTest();
            insert new Message__c(
                Role__c = 'assistant',
                Function_Name__c = 'metadataDrilldown',
                Function_Arguments__c = '{  "path": "layoutSections",  "toolingQuery": "SELECT Metadata FROM Layout WHERE EntityDefinitionId = \'01I7i0000030Ciy\'"}',
                Thread__c = testChat.Id
            );
            Test.stopTest();

            //Verify results
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                            FROM Message__c 
                                            WHERE Thread__c = :testChat.Id
                                            ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('metadataDrilldown', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('metadataDrilldown', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains('[{"customLabel":false,"detailHeading":true,"editHeading":true,'), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('The \'Chat__c-Chat Layout\' page layout has the following fields:  1. Information:'), 'Unexpected assistant content');
        }
    }

    //Test getURL function call
    @isTest
    static void testGetURL(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'URL retrieval request'
                            LIMIT 1];
        //Get Test user
        User testUser = [SELECT Id
                        FROM User
                        WHERE FirstName = :'SetupAI'];

        System.runAs(testUser){
            //Run test
            Test.startTest();
            insert new Message__c(
                Role__c = 'assistant',
                Function_Name__c = 'getURL',
                Function_Arguments__c = '{}',
                Thread__c = testChat.Id
            );
            Test.stopTest();

            //Verify results
            Message__c[] messages = [SELECT Name, Role__c, Content__c, Function_Name__c, Function_Arguments__c 
                                            FROM Message__c 
                                            WHERE Thread__c = :testChat.Id
                                            ORDER BY Id];
            System.assertEquals(4, messages.size(), 'Unexpected number of messages');
            System.assertEquals('getURL', messages[1].Function_Name__c, 'Unexpected function call');
            System.assertEquals('assistant', messages[1].Role__c, 'Unexpected role on message');
            System.assertEquals('function', messages[2].Role__c, 'Unexpected role on message');
            System.assertEquals('getURL', messages[2].Function_Name__c, 'Unexpected function call');
            System.assert(messages[2].Content__c.contains(Url.getOrgDomainUrl().toExternalForm()), 'Unexpected function content');
            System.assertEquals('assistant', messages[3].Role__c, 'Unexpected role on message');
            System.assert(messages[3].Content__c.contains('Your URL is ' + Url.getOrgDomainUrl().toExternalForm() + '.'), 'Unexpected assistant content');
        }
    }

    

}