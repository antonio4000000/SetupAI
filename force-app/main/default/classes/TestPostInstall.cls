/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-14
 * Description: Test coverage for post install
*/

@isTest
public with sharing class TestPostInstall {
    
    @isTest
    static void testInstall(){
        //Run test
        Test.startTest();
        PostInstall pi = new PostInstall();
        Test.testInstall(pi, null);
        Test.stopTest();

        //Verify results
        SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
        System.assertEquals(Date.today().month(),usage.SetupAI__Month__c);
    }
    
}