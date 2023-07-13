/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Used to submit requests to OpenAI Chat API
*/

public with sharing class ChatRequest {

    public String model;
    public Integer temperature;
    public ChatMessage[] messages;
    public ChatFunction[] functions;

    public ChatRequest(String model, Integer temperature, ChatMessage[] messages, ChatFunction[] functions){
        this.model = model;
        this.temperature = temperature;
        this.messages = messages;
        this.functions = functions;
    }

    public String serialize(){
        String processed = JSON.serialize(this,true);
        //Don't maintain null values except content on messages
        Map<String,Object> untyped = (Map<String,Object>)JSON.deserializeUntyped(processed);
        List<Object> messages = (List<Object>)JSON.deserializeUntyped(JSON.serialize(untyped.get('messages')));
        List<Object> newMessages = new List<Object>();
        for(Object message : messages){
            Map<String, Object> parsedMessage = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(message));
            if(parsedMessage.get('role') == 'assistant'){
                if(!parsedMessage.containsKey('content')){
                    parsedMessage.put('content', null);
                }
                if(parsedMessage.containsKey('function_call') && parsedMessage.get('function_call') != null){
                    Map<String,Object> functionCall = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedMessage.get('function_call')));
                    if(!functionCall.containsKey('name')){
                        parsedMessage.remove('function_call');
                    }
                }
            }
            newMessages.add(parsedMessage);
        }
        untyped.put('messages', newMessages);
        return JSON.serialize(untyped,false);
    }

    //Message in chat
    public class ChatMessage {
        public ChatMessage(String role, String content){
            this.role = role;
            this.content = content;
        }
        public String role;
        public String content;
        public String name;
        public ChatMessageFunctionCall function_call;
        public Integer completionTokens;
        public Integer promptTokens;
    }
    //Represents a function call by the assistant in a ChatMessage
    public class ChatMessageFunctionCall {
        public String name;
        public String arguments;
    }
    //Represents a function that the assistant can call
    public class ChatFunction {
        public ChatFunction(Function__mdt function){
            this.name = function.MasterLabel;
            this.description = function.Description__c;
            if(function.Properties__r != null){
                this.required = new String[]{};
                Map<String,Property> properties = new Map<String,Property>();
                for(Function_Property__mdt prop : function.Properties__r){
                    properties.put(prop.MasterLabel,new Property(prop));
                    if(prop.Required__c)this.required.add(prop.MasterLabel);
                }
                this.parameters = new Parameters('object',properties);
            }
        }
        public String name;
        public String description;
        public Parameters parameters;
        public String[] required;
    }
    //Represents the parameters passed into a ChatFunction
    public class Parameters {
        public Parameters(String type, Map<String,Property> properties){
            this.type = type;
            this.properties = properties;
        }
        public String type;
        public Map<String,Property> properties;
    }
    //Represents properties passed in as Parameters into ChatFunction
    public class Property {
        public Property(Function_Property__mdt prop){
            this.type = prop.Type__c;
            this.description = prop.Description__c;
            this.enum_x = prop.Enumerated_Values__c?.split('\n');
        }
        public String type;
        public String description;
        public String[] enum_x;
    }

}