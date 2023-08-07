/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-02-10
 * Description: Interfaces with APIs
*/

public with sharing class Callout {

    //Set to false for test setup methods to avoid callouts
    public static Boolean testSetup = false;

    //Custom exception for handling errors
    public class CalloutException extends Exception{}

    //Error codes for error handling
    public static Set<Integer> errorCodes = new Set<Integer>{400,401,402,403,404,405};
    
    //Http for sending requests
    public static Http h = new Http();

    public static String execute(String namedCred, String endpoint, String method, String body, Map<String, String> headers){
        //Retrieve endpoint with friendly name
        Endpoint__mdt e = [SELECT Endpoint__c FROM Endpoint__mdt WHERE MasterLabel = :endpoint WITH SECURITY_ENFORCED];
        return execute(
            'callout:' + namedCred + e.Endpoint__c, 
            method, 
            body, 
            headers
        );
    }

    //Call this Salesforce org
    public static String internalExecute(String endpoint, String method, String body, Map<String, String> headers){
        return execute(
            URL.getSalesforceBaseUrl().toExternalForm() + endpoint, 
            method, 
            body, 
            new Map<String, String>{'Authorization'=>'Bearer ' + UserInfo.getSessionId()}
        );
    }

    //Execute callouts
    private static String execute(String completeURL, String method, String body, Map<String, String> headers){
        if(!testSetup){
            //Construct callout
            HttpRequest req = new HttpRequest();
            req.setEndpoint(completeURL);
            req.setMethod(method);
            req.setTimeout(120000);
            if(body != null) req.setBody(body);
            if(headers != null && headers.size() > 0){
                for(String key : headers.keySet()){
                    req.setHeader(key, headers.get(key));
                }
            }
            req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
            //Execute request
            HttpResponse res = h.send(req);
            //Handle and return response
            if(!errorCodes.contains(res.getStatusCode())){
                return res.getBody();
            }else{
                throw new CalloutException(res.getBody());
            }  
        }else{return 'success';}
    }

}