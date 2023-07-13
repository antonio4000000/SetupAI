/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interfaces Salesforce objects with OpenAIs chat API
*/

public with sharing class ChatInterface {

    //Get Model name for given abbreviation
    private static String getModel(String modelAbbr){
        return [SELECT MasterLabel 
                FROM SetupAI__Model__mdt
                WHERE SetupAI__Abbreviation__c = :modelAbbr].MasterLabel;
    }
  

}