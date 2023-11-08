/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-06
 * Description: Handle token totaling with requests
*/

public with sharing class Tokenizer {

    // Static variable to hold the default organization level custom setting
    private static SetupAI__Token_Usage__c usage;

    public static SetupAI__Token_Usage__c getUsage() {
        if (usage == null) {
            usage = SetupAI__Token_Usage__c.getOrgDefaults();
            
            // If the custom setting does not exist, instantiate a new one
            if (usage == null) {
                usage = new SetupAI__Token_Usage__c();
                usage.SetupOwnerId = UserInfo.getOrganizationId();
                usage.SetupAI__Month__c = Date.today().month();
                usage.SetupAI__Tokens_Used__c = 0;
                upsert usage; // Perform DML operation to save the new defaults
            } else if (Date.today().month() != usage.SetupAI__Month__c) {
                resetMonthlyUsage(); // Reset usage for new month
            }
        }
        return usage;
    }

    private static void resetMonthlyUsage() {
        usage.SetupAI__Month__c = Date.today().month();
        usage.SetupAI__Tokens_Used__c = 0;
        upsert usage; // Perform DML operation to save the reset
        usage = null; // Clear the static variable so that it is re-queried with the new values next time
    }
   
    @AuraEnabled(cacheable=true)
    //Lets you know if max tokens exceeded
    public static Boolean maxExceeded(){
        //If a custom token was saved, we don't want tokens exceeded to come back as true.
        Integer count = Database.countQuery('SELECT COUNT() FROM SetupAI__Internal_API_Secret__mdt');
        getUsage();
        return count == 0 && usage.SetupAI__Tokens_Used__c >= usage.SetupAI__Max__c;
    }

    // Method to update current token usage
    public static void updateUsage(Integer newTokens) {
        if(Database.countQuery('SELECT COUNT() FROM SetupAI__Internal_API_Secret__mdt') == 0){
            getUsage(); // Ensure usage is initialized
            // Set the new value to the custom setting field
            usage.SetupAI__Tokens_Used__c += newTokens;
            
            // Perform the upsert DML operation
            upsert usage;
            // Clear the static variable so that it will be re-queried the next time it's accessed
            usage = null;
        }
    }
}