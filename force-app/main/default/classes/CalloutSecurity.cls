/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-14
 * Description: Retrieve API secret from settings
*/

public with sharing class CalloutSecurity {

    public class CalloutSecurityException extends Exception{}
    
    //Retrieve OpenAI API Key
    public static String getOpenAIKey(){
        if(customKeySaved()){
            //If parameter to send to LMO doesn't match, fix it
            if(!FeatureManager.usingCustomAPIKey()){
                FeatureManager.setUsingCustomAPIKey(true);
            }
            return SetupAI__GPT_Settings__c.getOrgDefaults().API_Key__c;
        }else{
            //If parameter to send to LMO doesn't match, fix it
            if(FeatureManager.usingCustomAPIKey()){
                FeatureManager.setUsingCustomAPIKey(false);
            }
            SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
            return [SELECT Key__c
                    FROM API_Secret__mdt
                    WHERE MasterLabel = :(Callout.useBackup ? 'Backup' : 'Default')
                    WITH SECURITY_ENFORCED].Key__c;
        }
    }

    //Returns true if a custom API key was saved
    public static Boolean customKeySaved(){
        SetupAI__GPT_Settings__c settings = SetupAI__GPT_Settings__c.getOrgDefaults();
        return settings != null && settings.API_Key__c != null;
    }

    //Sets flag to use backup key if primary key is turned off/compromised
    @future
    public static void setBackupKeyTrue(){
        SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
        usage.SetupAI__Use_Backup__c = true;
        update usage;
    }

    //Returns backup key indicator flag
    public static Boolean getBackupKeyStatus(){
        return SetupAI__Token_Usage__c.getOrgDefaults().SetupAI__Use_Backup__c;
    }

}