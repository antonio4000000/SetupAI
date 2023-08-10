/*
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-04-17
 * Description: Allows querying of Metadata via Tooling API
 */

public with sharing class ToolingAPI {

    //Get endpoint metadata
    public static String getEndpoint(String name){
        Endpoint__mdt endpoint = [SELECT Endpoint__c
                                  FROM Endpoint__mdt
                                  WHERE DeveloperName =:name
                                  WITH SECURITY_ENFORCED];
        return endpoint.Endpoint__c;
    }

    //Retrieve all SObjects from Tooling API
    public static ToolingSObjectsResponse getSObjects(){
        return ToolingSObjectsResponse.parse(
            Callout.internalExecute(
                getEndpoint('Tooling') + 'sobjects', 
                'GET', 
                null, 
                new Map<String, String>{'Content-Type'=>'application/json'}
            )
        );
    }

    //Return describe information on SObject
    public static String describeSObject(String sobjectType){
        return Callout.internalExecute(
            getEndpoint('Tooling') + 'sobjects/' + sobjectType + '/describe', 
            'GET', 
            null, 
            new Map<String, String>{'Content-Type'=>'application/json'}
        );
    }
    
    //Execute Tooling query
    public static String query(String query){
        return Callout.internalExecute(
            getEndpoint('Tooling') + 'query?q=' + EncodingUtil.urlEncode(query, 'UTF-8'), 
            'GET', 
            null, 
            new Map<String, String>{'Content-Type'=>'application/json'}
        );
    }

}