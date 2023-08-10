/* 
 * Author:          Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:         2022-03-20
 * Description:     Helper Apex methods
*/

public class Utils {

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

}