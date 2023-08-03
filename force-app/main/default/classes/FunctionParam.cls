/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Parameters to Apex functions that can be called by AI
*/

public with sharing class FunctionParam {
    
    public class SOQL{
        public String type;
        public String query;
    }

    public static FunctionParam.SOQL parseSOQL(String args){
        return (FunctionParam.SOQL)JSON.deserialize(args, FunctionParam.SOQL.class);
    }

    public class describeTooling{
        public String object_x;
    }

    public static FunctionParam.describeTooling parseDescribeTooling(String args){
        return (FunctionParam.describeTooling)JSON.deserialize(args, FunctionParam.describeTooling.class);
    }

    public class describeDrilldown{
        public String object_x;
        public String path;
    }

    public static FunctionParam.describeDrilldown parseDescribeDrilldown(String args){
        return (FunctionParam.describeDrilldown)JSON.deserialize(args, FunctionParam.describeDrilldown.class);
    }

    public class metadataDrilldown{
        public String path;
        public String toolingQuery;
    }

    public static FunctionParam.metadataDrilldown parseMetadataDrilldown(String args){
        return (FunctionParam.metadataDrilldown)JSON.deserialize(args, FunctionParam.metadataDrilldown.class);
    }

}