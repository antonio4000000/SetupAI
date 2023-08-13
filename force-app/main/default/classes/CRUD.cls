/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-02
 * Description: Validate user permissions
*/

public with sharing class CRUD {
    
    //Validates creation of SetupAI__Chat__c records
    public static Boolean createChat(){
        return (
            SetupAI__Chat__c.SObjectType.getDescribe().isCreateable() &&
            Schema.SObjectType.SetupAI__Chat__c.fields.Name.isCreateable() &&
            Schema.SObjectType.SetupAI__Chat__c.fields.SetupAI__Running__c.isCreateable()
        );
    }

    //Validates creation of SetupAI__Message__c records
    public static Boolean createMessage(){
        return (
            SetupAI__Message__c.SObjectType.getDescribe().isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Completion_Tokens__c.isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Content__c.isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Function_Arguments__c.isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Function_Name__c.isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Model__c.isCreateable() &&
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Prompt_Tokens__c.isCreateable() && 
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Role__c.isCreateable() && 
            Schema.SObjectType.SetupAI__Message__c.fields.SetupAI__Thread__c.isCreateable()
        );
    }

}