/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-14
 * Description: Retrieve API secret from settings
*/

public with sharing class CalloutSecurity {

    public class CalloutSecurityException extends Exception{}
    
    //Retrieve OpenAI API Key
    public static String getOpenAIKey(){
        if(FeatureManager.isUnlimited()){
            SetupAI__GPT_Settings__c settings = SetupAI__GPT_Settings__c.getOrgDefaults();
            if(settings != null && settings.API_Key__c != null){
                return settings.API_Key__c;
            }else{
                throw new CalloutSecurityException(Label.No_Key_Saved);
            }
        }else{
            return [SELECT Key__c
                    FROM API_Secret__mdt
                    WHERE MasterLabel = :'Default'
                    WITH SECURITY_ENFORCED].Key__c;
        }
    }

}