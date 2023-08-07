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

}