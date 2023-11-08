/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-14
 * Description: Retrieve API secret from settings
*/

public with sharing class CalloutSecurity {

    public class CalloutSecurityException extends Exception{}
    
    //Retrieve OpenAI API Key
    public static String getOpenAIKey(){
        Integer count = Database.countQuery('SELECT COUNT() FROM SetupAI__Internal_API_Secret__mdt');
        if(count == 0){
            return [SELECT Key__c
                    FROM API_Secret__mdt
                    WHERE MasterLabel = :'Default'
                    WITH SECURITY_ENFORCED].Key__c;
        }else if(count > 1){
            throw new CalloutSecurityException(Label.Multiple_Internal_Keys);
        }else{
            return [SELECT Key__c
                    FROM SetupAI__Internal_API_Secret__mdt
                    WITH SECURITY_ENFORCED
                    LIMIT 1].Key__c;
        }
    }

}