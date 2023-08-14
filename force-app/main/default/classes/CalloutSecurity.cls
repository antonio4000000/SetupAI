/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-14
 * Description: Retrieve API secret from settings
*/

public with sharing class CalloutSecurity {
    
    //Retrieve OpenAI API Key
    public static String getOpenAIKey(){
        return [SELECT Key__c
                FROM API_Secret__mdt
                WHERE MasterLabel = :'Default'
                WITH SECURITY_ENFORCED].Key__c;
    }

}