/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Converts Message__c records to ChatRequest.ChatMessage instances and vice versa
*/

public with sharing class MessageConvertor {

    //Get general system prompt
    public static String systemPrompt = SystemPromptHelper.getPrompt(SystemPromptHelper.PRIMARY_LABEL) + '\n';
                                
    //Convert records to classes
    public static ChatRequest.ChatMessage[] convert(Message__c[] messages){
        ChatRequest.ChatMessage[] toReturn = new ChatRequest.ChatMessage[]{};
        for(Message__c message : messages){
            message.Content__c = message.Role__c == 'system' ? systemPrompt + message.Content__c : message.Content__c; //append system prompt
            toReturn.add(new ChatRequest.ChatMessage(message));
        }
        return toReturn;
    }

    //Convert records to classes
    public static Message__c convert(ChatRequest.ChatMessage message, String chatId){
        return new Message__c(Role__c = message.role,
                              Content__c = message.role == 'system' ? message.content.remove(systemPrompt) : message.content, //Never save custom metadata system prompt
                              Completion_Tokens__c = message.completionTokens,
                              Prompt_Tokens__c = message.promptTokens,
                              Function_Name__c = message.function_call?.name,
                              Function_Arguments__c = message.function_call?.arguments,
                              Thread__c = chatId);
    }

}