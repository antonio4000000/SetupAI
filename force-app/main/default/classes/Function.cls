/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Function logic to be called by AI
*/

public with sharing class Function {

    //Executes specified action and saves results to chat
    public static void execute(String name, String arguments, String chatId){
        try{
            String results;
            switch on name {
                when 'soql' {
                    results = soql(FunctionParam.parseSOQL(arguments));
                }
                when 'getToolingObjects'{
                    results = getToolingObjects();
                }
                when 'describeToolingObject' {
                    results = describeToolingObject(FunctionParam.parseDescribeTooling(arguments));
                }
                when 'describeDrilldown' {
                    results = describeDrilldown(FunctionParam.parseDescribeDrilldown(arguments));
                }
                when 'getUserId'{
                    results = UserInfo.getUserId();
                }
            }
            insert new Message__c(Thread__c = chatId,
                                  Role__c = 'function',
                                  Content__c = results,
                                  Function_Name__c = name);
        }catch(Exception ex){
            insert new Message__c(Thread__c = chatId,
                                  Role__c = 'error',
                                  Content__c = ex.getMessage());
        }
    }
    
    //Execute SOQL Query
    public static String soql(FunctionParam.SOQL args){
        String query = SOQLModifier.modify(args.query);
        switch on args.type {
            when 'tooling'{
                return ToolingAPI.query(args.query);
            }
            when else {//if null, default to 'data'
                return JSON.serialize(Database.query(args.query));
            }
        }
    }

    //Return list of all Tooling API objects
    public static String getToolingObjects(){
        return JSON.serialize(ToolingAPI.getSObjects().getSObjectNames());
    }

    //Return information on Tooling API object specified(Returns keys in JSON object that AI can select from)
    public static String describeToolingObject(FunctionParam.describeTooling args){
        String describeResults = ToolingAPI.describeSObject(args.object_x);
        String keys = '';
        for(String key : ((Map<String,Object>)JSON.deserializeUntyped(describeResults)).keySet()){
            keys = keys + ';' + key;
        }
        return keys;
    }

    //Drillsdown into describe info
    public static String describeDrilldown(FunctionParam.describeDrilldown args){
        String describeResults = ToolingAPI.describeSObject(args.object_x);
        return JSONHelper.getJSONValue(describeResults,args.path);
    }

}