/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Converts Message__c records to ChatRequest.ChatMessage instances and vice versa
*/

public with sharing class MessageConvertor {
    
    //Convert records to classes
    public static ChatRequest.ChatMessage[] convert(Message__c[] messages){
        ChatRequest.ChatMessage[] toReturn = new ChatRequest.ChatMessage[]{};
        for(Message__c message : messages){
            toReturn.add(new ChatRequest.ChatMessage(message));
        }
        return toReturn;
    }

    //Convert records to classes
    public static Message__c convert(ChatRequest.ChatMessage message){
        return new Message__c(Role__c = message.role,
                              Content__c = message.content,
                              Completion_Tokens__c = message.completionTokens,
                              Prompt_Tokens__c = message.promptTokens,
                              Function_Name__c = message.function_call?.name,
                              Function_Arguments__c = message.function_call?.arguments);
    }

}