/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Function logic to be called by AI
*/

public with sharing class Function {

    public class FunctionException extends Exception{}

    //Executes specified action and saves results to chat
    public static void execute(String name, String arguments, String chatId){
        String content = '';
        try{
            switch on name {
                when 'soql' {
                    content = soql(FunctionParam.parseSOQL(arguments));
                }
                when 'toolingQuery' {
                    content = toolingQuery(FunctionParam.parseSOQL(arguments));
                }
                when 'getToolingObjects'{
                    content = getToolingObjects();
                }
                when 'getFields'{
                    content = getFields(FunctionParam.parseGetFields(arguments));
                }
                when 'getToolingFields'{
                    content = getToolingFields(FunctionParam.parseGetFields(arguments));
                }
                when 'getUserId'{
                    content = UserInfo.getUserId();
                }
                when 'metadataDrilldown'{
                    content = metadataDrilldown(FunctionParam.parseMetadataDrilldown(arguments));
                }
                when 'getURL'{
                    content = Url.getOrgDomainUrl().toExternalForm();
                }
                when 'getEndpoints'{
                    content = getEndpoints();
                }
            }
        }catch(Exception ex){
            content = ex.getMessage();
        }
        //Check message create permissions
        if(CRUD.createMessage()){
            insert new Message__c(Thread__c = chatId,
                                  Role__c = 'function',
                                  Content__c = content,
                                  Function_Name__c = name);
        }
    }
    
    //Execute SOQL Query
    public static String soql(FunctionParam.SOQL args){
        String query = SOQLModifier.modify(args.query);
        return query.toUpperCase().contains('COUNT()') ?
               String.valueOf(Database.countQuery(query)) :
               JSON.serialize(Database.query(query));
    }

    //Execute SOQL Query on Tooling API
    public static String toolingQuery(FunctionParam.SOQL args){
        return ToolingAPI.query(args.query);
    }

    //Return list of all Tooling API objects
    public static String getToolingObjects(){
        return JSON.serialize(ToolingAPI.getSObjects().getSObjectNames());
    }

    //Return list of all fields on a given SObject
    public static String getFields(FunctionParam.getFields args){
        //Initialize return type
        List<Map<String,String>> allFields = new List<Map<String,String>>();
        //Loop through fields
        for(Schema.SObjectField field : Schema.getGlobalDescribe().get(args.object_x).getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            allFields.add(new Map<String,String>{
                'label'=>fieldDescribe.getLabel(),
                'apiName'=>fieldDescribe.getName(),
                'type'=>String.valueOf(fieldDescribe.getType())
            });
        }
        return JSON.serialize(allFields);
    }

    //Return list of all fields on a given Tooling API SObject
    public static String getToolingFields(FunctionParam.getFields args){
        //Initialize return type
        List<Map<String,Object>> allFields = new List<Map<String,Object>>();
        //Loop through fields
        for(Object field : ToolingAPI.getFields(args.object_x)){
            //Split out field
            Map<String,Object> fieldDeserialized = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(field));
            //Map new results
            allFields.add(new Map<String,Object>{
                'label'=>fieldDeserialized.get('label'),
                'apiName'=>fieldDeserialized.get('name'),
                'type'=>fieldDeserialized.get('type')
            });
        }
        return JSON.serialize(allFields);
    }

    //Drilldown into Tooling API Metadata
    public static String metadataDrilldown(FunctionParam.metadataDrilldown args){
        //Query from Tooling API
        Object metadataRecords = ((Map<String, Object>)JSON.deserializeUntyped(
            ToolingAPI.query(args.toolingQuery)
        )).get('records');
        //Get records from query results
        List<Object> recordsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(metadataRecords));
        //Verify record list returns only one record
        if(recordsList.size() > 1){
            throw new FunctionException(Label.Multiple_Metadata_Records);
        }
        //Deserialize first item in record list
        Map<String, Object> resultsJSON = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(recordsList[0]));
        //Verify query returned metadata
        if(resultsJSON.containsKey('Metadata')){
            //Get metadata from query
            String metadata = JSON.serialize(resultsJSON.get('Metadata'));
            //Get value at specified path
            String pathValue = JSONHelper.getJSONValue(metadata, args.path);
            //If object, just return keys
            if(pathValue.startsWith('{') && pathValue.endsWith('}')){
                Map<String, Object> metadataJSON = (Map<String, Object>)JSON.deserializeUntyped(pathValue);
                String returnKeys = 'Here are the keys at specified path: ';
                for(String key : metadataJSON.keySet()){
                    returnKeys = returnKeys + key + ', ';
                }
                return returnKeys.removeEnd(', ');
            }else{
                return pathValue;
            }
        }else{
            throw new FunctionException(Label.Metadata_Not_Found);
        }
    }

    //Return serialized list of all URL__mdt records
    public static String getEndpoints(){
        Utils.InternalEndpoint[] toReturn = new Utils.InternalEndpoint[]{};
        for(URL__mdt url : [SELECT MasterLabel, Endpoint__c, Details__c
                            FROM URL__mdt]){
            toReturn.add(new Utils.InternalEndpoint(url));
        }
        return JSON.serialize(toReturn);
    }

}