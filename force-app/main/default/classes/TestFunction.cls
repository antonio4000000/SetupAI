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
        //SOQL
        TestDataFactory.createChatWithSystemAndUser(
            /** Summary */  'Query Account',
            /** System */   'Execute SOQL query "SELECT AccountNumber FROM Account WHERE Name = \'Test Account\'',
            /** User */     'What is the Account number of the account named \'Test Account\'?'
        );
        //Tooling SOQL
        TestDataFactory.createChatWithSystemAndUser(
            /** Summary */  'MessageTriggerHandler Apex Class Summary',
            /** System */   '1. Retrieve the MessageTriggerHandler Apex class:- This will allow you to read the class and summarize its contents for the user.- Run this Tooling API SOQL query "SELECT Name, Body FROM ApexClass WHERE Name = \'MessageTriggerHandler\'"- If a result is returned, assess the class body contents. Look for the methods and their functionality, the variables and their usage, and any patterns or best practices followed. Summarize these findings for the user. If there are any best practices not followed or errors, make some simple recommendations they could do to fix the class or make it more efficient.- If no class was found, re-run the query but with this where clause: "WHERE Name LIKE \'%MessageTriggerHandler%\'". If you find a class with a name just 1-2 characters off from MessageTriggerHandler, summarize that class for the user following the guidelines in the previous step.- If still no class is found, let the user know you couldn\'t find the class they were referring to, and ask them to double check the exact name of the class.',
            /** User */     'Summarize the MessageTriggerHandler Apex class'
        );
        //getToolingObjects
        TestDataFactory.createChatWithSystemAndUser(
            /** Summary */  'Accessible objects through Tooling API summary',
            /** System */   '1. Retrieve all accessible objects through the Tooling API:- The Tooling API provides access to metadata and other Salesforce org data. It\'s used for development, to create and test code, retrieve metadata, and so on.- To retrieve all objects accessible through the Tooling API, run this Tooling API SOQL query: "SELECT SObjectType FROM sObjects"- This will return a list of all the objects that the Tooling API can access. The list will include standard objects, custom objects, and other metadata types.- If the user wants to know about a specific object, they can filter the results by adding a WHERE clause to the query, like this: "SELECT SObjectType FROM sObjects WHERE SObjectType = \'{OBJECT_NAME}\'"- If the object is not returned in the query results, it means that the object is not accessible through the Tooling API. In this case, the user might need to use the Metadata API or another API to access the object.- If the object is returned in the query results, it means that the object is accessible through the Tooling API. The user can then use other Tooling API queries to retrieve more information about the object, such as its fields, relationships, and so on.',
            /** User */     'What objects are accessible to me through the Tooling API?'
        );
        //describeToolingObject
        TestDataFactory.createChatWithSystemAndUser(
            /** Summary */  'ApexClass tooling object fields summary',
            /** System */   '1. Retrieve the fields on the ApexClass object:- The ApexClass object in the Tooling API has several fields that can be accessed. These fields provide information about the Apex class, such as its name, body, status, namespace prefix, etc.- Run this Tooling API SOQL query "SELECT * FROM ApexClass" to retrieve all fields on the ApexClass object.- If you want to retrieve specific fields, you can modify the query to include only those fields. For example, "SELECT Id, Name, Body, Status, NamespacePrefix FROM ApexClass".- Here are some of the fields you can access on the ApexClass object:  - Id: The unique identifier of the Apex class.  - Name: The name of the Apex class.  - Body: The source code of the Apex class.  - Status: The status of the Apex class (Active or Inactive).  - NamespacePrefix: The namespace prefix of the Apex class, if it belongs to a managed package.  - ApiVersion: The API version for the Apex class.  - IsValid: Indicates whether the Apex class is valid.  - LengthWithoutComments: The length of the Apex class body excluding comments.  - CreatedDate: The date and time when the Apex class was created.  - LastModifiedDate: The date and time when the Apex class was last modified.  - SymbolTable: A representation of the Apex class\'s public and private methods, properties, and inner classes, including their signatures.- Note that some fields may not be accessible depending on the user\'s permissions and the organization\'s settings.',
            /** User */     'What fields can you access on the ApexClass tooling object?'
        );
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

    //Test getToolingObjects function call
    @isTest
    static void testGetToolingObjects(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'Accessible objects through Tooling API summary'
                            LIMIT 1];
        
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
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
        System.assertEquals(5, messages.size(), 'Unexpected number of messages');
        System.assertEquals('getToolingObjects', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('getToolingObjects', messages[3].Function_Name__c, 'Unexpected function call');
        System.assert(messages[3].Content__c.contains('["AIApplication","AIApplicationConfig","AIReplyRecommendationsSettings"'), 'Unexpected function content');
        System.assertEquals('assistant', messages[4].Role__c, 'Unexpected role on message');
        System.assert(messages[4].Content__c.contains('The objects accessible to you through the Tooling API are:  - AIApplication - AIApplicationConfig - AIReplyRecommendationsSettings - AccessControlPolicy - AccountInsightsSettings'), 'Unexpected assistant content');
    }

    //Test describeToolingObject function call
    @isTest
    static void testDescribe(){
        //Setup test
        Test.setMock(HttpCalloutMock.class, new OpenAIMock());
        Chat__c testChat = [SELECT Id
                            FROM Chat__c
                            WHERE Name = :'ApexClass tooling object fields summary'
                            LIMIT 1];
        
        //Run test
        Test.startTest();
        insert new Message__c(
            Role__c = 'assistant',
            Function_Name__c = 'describeToolingObject',
            Function_Arguments__c = '{"object_x": "ApexClass"}',
            Thread__c = testChat.Id
        );
        Test.stopTest();

        //Verify results
        Message__c[] messages = [SELECT Name, SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c 
                                 FROM SetupAI__Message__c 
                                 WHERE SetupAI__Thread__c = :testChat.Id
                                 ORDER BY Id];
        System.assertEquals(5, messages.size(), 'Unexpected number of messages');
        System.assertEquals('describeToolingObject', messages[2].Function_Name__c, 'Unexpected function call');
        System.assertEquals('assistant', messages[2].Role__c, 'Unexpected role on message');
        System.assertEquals('function', messages[3].Role__c, 'Unexpected role on message');
        System.assertEquals('describeToolingObject', messages[3].Function_Name__c, 'Unexpected function call');
        System.assert(messages[3].Content__c.contains(';actionOverrides;activateable;associateEntityType'), 'Unexpected function content');
        System.assertEquals('assistant', messages[4].Role__c, 'Unexpected role on message');
        System.assert(messages[4].Content__c.contains('Here are the fields that you can access on the ApexClass tooling object:  - actionOverrides - activateable - associateEntityType'), 'Unexpected assistant content');
    }

}