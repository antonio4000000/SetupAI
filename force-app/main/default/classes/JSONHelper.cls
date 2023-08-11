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
                if(Utils.isPrimitive(value) || Utils.isList(value)) break;
            }
        } else {
            value = oldMap.get(path);
        }
        return JSON.serialize(value);
    }

}