/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-03
 * Description: Retrieves System Prompt information from custom metadata
*/

public with sharing class SystemPromptHelper {

    public static final String TITLE_LABEL = 'Title';
    public static final String HELPER_LABEL = 'Helper';
    public static final String PRIMARY_LABEL = 'Primary';
    
    //Get System Prompt
    public static String getPrompt(String label){
        return [SELECT SetupAI__Content__c
                FROM SetupAI__System_Prompt__mdt
                WHERE MasterLabel = :label
                WITH SECURITY_ENFORCED].Content__c;
    }

}