/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-06
 * Description: Handle token totaling with requests
*/

public with sharing class Tokenizer {

    public class TokenizerException extends Exception{}

    // Static variable to hold the default organization level custom setting
    private static SetupAI__Token_Usage__c usage;

    public static SetupAI__Token_Usage__c getUsage() {
        if(FeatureManager.hasSetupAIAccess()){
            if (usage == null) {
                usage = SetupAI__Token_Usage__c.getOrgDefaults();
                
                // If the custom setting does not exist, instantiate a new one
                if (usage == null) {
                    usage = new SetupAI__Token_Usage__c();
                    usage.SetupOwnerId = UserInfo.getOrganizationId();
                    usage.SetupAI__Month__c = Date.today().month();
                    upsert usage; // Perform DML operation to save the new defaults
                } else if (Date.today().month() != usage.SetupAI__Month__c) {
                    resetMonthlyUsage(); // Reset usage for new month
                }
            }
            return usage;
        }else{
            throw new TokenizerException(Label.No_SetupAI_Access);
        }
    }

    private static void resetMonthlyUsage() {
        usage.SetupAI__Month__c = Date.today().month();
        if(FeatureManager.inputTokens() != 0){FeatureManager.setInputTokens(0);}
        if(FeatureManager.outputTokens() != 0){FeatureManager.setOutputTokens(0);}
        upsert usage; // Perform DML operation to save the reset
        usage = null; // Clear the static variable so that it is re-queried with the new values next time
    }
   
    @AuraEnabled(cacheable=true)
    //Lets you know if max tokens exceeded
    public static Boolean maxExceeded(){
        return !CalloutSecurity.customKeySaved() &&
               FeatureManager.amountSpent() >= FeatureManager.tokenLimit();
    }

    // Method to update current token usage
    public static void updateUsage(Integer inputTokens, Integer outputTokens) {
        if(!CalloutSecurity.customKeySaved()){
            FeatureManager.setInputTokens(inputTokens + FeatureManager.inputTokens());
            FeatureManager.setOutputTokens(outputTokens + FeatureManager.outputTokens());
        }
    }
}