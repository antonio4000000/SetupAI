/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-14
 * Description: Post-install script creates first custom metadata record upon installation.
*/

public with sharing class PostInstall implements InstallHandler {
    
    //Create default custom setting if it doesn't exist
    public void onInstall(InstallContext context){
        //Get custom field/setting to check security
        Schema.DescribeSObjectResult tokenUsage = Schema.getGlobalDescribe().get('SetupAI__Token_Usage__c').getDescribe();
        Schema.DescribeFieldResult month = tokenUsage.fields.getMap().get('SetupAI__Month__c').getDescribe();
        Schema.DescribeFieldResult ownerId = tokenUsage.fields.getMap().get('SetupOwnerId').getDescribe();
        //Verify security
        if(tokenUsage.isUpdateable() &&
           month.isUpdateable() &&
           ownerId.isUpdateable() &&
           //Check default needs to be populated
           SetupAI__Token_Usage__c.getOrgDefaults() != null &&
           SetupAI__Token_Usage__c.getOrgDefaults().SetupAI__Month__c == null){
            //Create default custom setting
            SetupAI__Token_Usage__c usage = new SetupAI__Token_Usage__c();
            usage.SetupOwnerId = UserInfo.getOrganizationId();
            usage.SetupAI__Month__c = Date.today().month();
            upsert usage;
        }
    }

}