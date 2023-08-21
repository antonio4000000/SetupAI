/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Parameters to Apex functions that can be called by AI
*/

public with sharing class FunctionParam {
    
    public class SOQL{
        public String query;
    }

    public static FunctionParam.SOQL parseSOQL(String args){
        return (FunctionParam.SOQL)JSON.deserialize(args, FunctionParam.SOQL.class);
    }

    public class getFields{
        public String object_x;
    }

    public static FunctionParam.getFields parseGetFields(String args){
        return (FunctionParam.getFields)JSON.deserialize(args, FunctionParam.getFields.class);
    }

    public class metadataDrilldown{
        public String path;
        public String toolingQuery;
    }

    public static FunctionParam.metadataDrilldown parseMetadataDrilldown(String args){
        return (FunctionParam.metadataDrilldown)JSON.deserialize(args, FunctionParam.metadataDrilldown.class);
    }

}