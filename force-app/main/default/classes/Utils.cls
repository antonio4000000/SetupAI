/* 
 * Author:          Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:         2022-03-20
 * Description:     Helper Apex methods
*/

public with sharing class Utils {

    //Default model for chats
    public static FINAL String DEFAULT_MODEL = [SELECT SetupAI__Model__c
                                                FROM SetupAI__API_Secret__mdt
                                                WHERE MasterLabel =:'Default'
                                                WITH SECURITY_ENFORCED].Model__c;

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
        if(CalloutSecurity.customKeySaved()){
            SetupAI__GPT_Settings__c settings = SetupAI__GPT_Settings__c.getOrgDefaults();
            return settings == null || settings.Model__c == null || settings.Model__c == '' ? 
                   DEFAULT_MODEL :
                   settings.Model__c;
        }else{
            return DEFAULT_MODEL;
        }
    }

}