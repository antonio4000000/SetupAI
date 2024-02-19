/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-14
 * Description: Retrieve API secret from settings
*/

public with sharing class CalloutSecurity {

    public class CalloutSecurityException extends Exception{}
    
    //Retrieve OpenAI API Key
    public static String getOpenAIKey(){
        if(FeatureManager.hasSetupAIAccess()){
            SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
            return [SELECT Key__c
                    FROM API_Secret__mdt
                    WHERE MasterLabel = :(Callout.useBackup ? 'Backup' : 'Default')
                    WITH SECURITY_ENFORCED].Key__c;
        }else{
            throw new CalloutSecurityException(Label.No_SetupAI_Access);
        }
    }

    //Returns true if a custom API key was saved
    public static Boolean customKeySaved(){
        return [SELECT Id FROM NamedCredential WHERE MasterLabel = :'SetupAI'].size() > 0;
    }

    //Sets flag to use backup key if primary key is turned off/compromised
    @future
    public static void setBackupKeyTrue(){
        if(FeatureManager.hasSetupAIAccess()){
            SetupAI__Token_Usage__c usage = SetupAI__Token_Usage__c.getOrgDefaults();
            usage.SetupAI__Use_Backup__c = true;
            update usage;
        }else{
            throw new CalloutSecurityException(Label.No_SetupAI_Access);
        }
    }

    //Sets Custom API Key feature(future method called directly before callouts)
    public static void flipCustomKeyFlag(){
        FeatureManager.setUsingCustomAPIKey(
            !FeatureManager.usingCustomAPIKey()
        );
    }

    //Returns backup key indicator flag
    public static Boolean getBackupKeyStatus(){
        if(FeatureManager.hasSetupAIAccess()){
            return SetupAI__Token_Usage__c.getOrgDefaults().SetupAI__Use_Backup__c;
        }else{
            throw new CalloutSecurityException(Label.No_SetupAI_Access);
        }
    }

}