/*
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-05-16
 * Description: Performs JSON manipulations
 */

public with sharing class JSONHelper {

    //Get value at path in JSON body
    public static String getJSONValue(String jsonString, String path) {
        Map<String, Object> oldMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Object value = oldMap;
        if (path.contains('.')) {
            for (String key : path.split('\\.')) {
                value = ((Map<String, Object>) value).get(key);
                if(Utils.isPrimitive(value)) break;
            }
        } else {
            value = oldMap.get(path);
        }
        return JSON.serialize(value);
    }
    
    //Return simplified JSON with all fields specified
    public static String getFieldValues(String jsonString, String[] fields){
        Map<String, Object> oldMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Map<String, Object> newMap = new Map<String, Object>();
        for(String field : fields){
            if(oldMap.containsKey(field)){
                newMap.put(field, oldMap.get(field));
            }
        }
        return JSON.serialize(newMap);
    }

}