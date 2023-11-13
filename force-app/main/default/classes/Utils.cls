/* 
 * Author:          Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:         2022-03-20
 * Description:     Helper Apex methods
*/

public with sharing class Utils {

    //Checks if specified value is a primitive data type
    public static Boolean isPrimitive(Object value){
        return value instanceof Boolean || value instanceof String || value instanceof Integer ||
               value instanceof Double || value instanceof Decimal || value instanceof Date ||
               value instanceof DateTime || value instanceof Time || value instanceof Blob ||
               value instanceof Id || value instanceof Long;
    }

    //Returns true if value passed in is a list
    //Assumes value is non-primitive
    public static Boolean isList(Object value){
        try{
            Map<String, Object> deserialized = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(value));
            return deserialized.size() == 0;
        }catch(Exception e){
            return true;
        }
    }

    //Gets body of text static resource
    public static String getStaticResource(String nameOfFile){
        return [SELECT Body
                FROM StaticResource 
                WHERE Name = :nameOfFile].Body.toString();
    }

    //Generate random number string
    public static String getRandom(){
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        return EncodingUtil.convertToHex(hash);
    }

    //Wrapper for URL__mdt settings
    public class InternalEndpoint{
        public String name;
        public String endpoint;
        public String details;
        public InternalEndpoint(URL__mdt settings){
            this.name = settings.MasterLabel;
            this.endpoint = settings.Endpoint__c;
            this.details = settings.Details__c;
        }
    }

    //Returns model to use in chats
    public static String getModel(){
        SetupAI__Internal_API_Secret__mdt internalSecret = [SELECT Model__c 
                                                            FROM SetupAI__Internal_API_Secret__mdt 
                                                            LIMIT 1];
        return internalSecret == null || internalSecret.Model__c == null || internalSecret.Model__c == '' ? 
               'gpt-3' :
               internalSecret.Model__c;
    }

}