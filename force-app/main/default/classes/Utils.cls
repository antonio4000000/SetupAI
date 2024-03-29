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
                WHERE Name = :nameOfFile
                WITH SECURITY_ENFORCED].Body.toString();
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
        return DEFAULT_MODEL;
    }

    //Prevents HTML from displaying in chat
    public static String sanitizeHtml(String input) {
        if (String.isEmpty(input)) {
            return input;
        }
        // Escape all HTML entities
        String sanitized = input.escapeHtml4();
        // Unescape specific characters for readability
        sanitized = sanitized.replace('&#39;', '\'') // Apostrophe
                             .replace('&quot;', '"') // Double Quote
                             .replace('&amp;', '&');  // Ampersand
        return sanitized;
    }

    //returns path after domain in url
    public static String getEndpointPath(String urlString){
        String[] parts = urlString.split('//', 2);
        String domainPart = parts.size() > 1 ? parts[1] : parts[0];
        return '/' + domainPart.substringAfter('/');
    }

}