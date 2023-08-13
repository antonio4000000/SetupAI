/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-02
 * Description: Validate user permissions
*/

public with sharing class CRUD {
    
    //Validates creation of Chat__c records
    public static Boolean createChat(){
        return (
            Chat__c.SObjectType.getDescribe().isCreateable() &&
            Schema.SObjectType.Chat__c.fields.Name.isCreateable() &&
            Schema.SObjectType.Chat__c.fields.Running__c.isCreateable()
        );
    }

    //Validates creation of Message__c records
    public static Boolean createMessage(){
        return (
            Message__c.SObjectType.getDescribe().isCreateable() &&
            Schema.SObjectType.Message__c.fields.Completion_Tokens__c.isCreateable() &&
            Schema.SObjectType.Message__c.fields.Content__c.isCreateable() &&
            Schema.SObjectType.Message__c.fields.Function_Arguments__c.isCreateable() &&
            Schema.SObjectType.Message__c.fields.Function_Name__c.isCreateable() &&
            Schema.SObjectType.Message__c.fields.Model__c.isCreateable() &&
            Schema.SObjectType.Message__c.fields.Prompt_Tokens__c.isCreateable() && 
            Schema.SObjectType.Message__c.fields.Role__c.isCreateable() && 
            Schema.SObjectType.Message__c.fields.Thread__c.isCreateable()
        );
    }

}