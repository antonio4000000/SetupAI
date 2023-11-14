/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-14
 * Description: Test coverage for post install
*/

@isTest
public class TestPostInstall {
    
    @isTest
    static void testInstall(){
        //Run test
        Test.startTest();
        PostInstall pi = new PostInstall();
        Test.testInstall(pi, null);
        Test.stopTest();

        //Verify results
        SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
        System.assertEquals(1500000,usage.SetupAI__Max__c);
        System.assertEquals(0,usage.SetupAI__Tokens_Used__c);
        System.assertEquals(Date.today().month(),usage.SetupAI__Month__c);
    }
    
}