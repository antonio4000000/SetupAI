/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Converts Message__c records to ChatRequest.ChatMessage instances and vice versa
*/

public with sharing class MessageConvertor {

    //Get general system prompt
    public static String systemPrompt = SystemPromptHelper.getPrompt(SystemPromptHelper.PRIMARY_LABEL) + '\n';
                                
    //Convert records to classes
    public static ChatRequest.ChatMessage[] convert(SetupAI__Message__c[] messages){
        ChatRequest.ChatMessage[] toReturn = new ChatRequest.ChatMessage[]{
            new ChatRequest.ChatMessage(
                'system',
                systemPrompt
            )
        };
        for(SetupAI__Message__c message : messages){
            message.SetupAI__Content__c = message.SetupAI__Content__c;
            toReturn.add(new ChatRequest.ChatMessage(message));
        }
        return toReturn;
    }

    //Convert records to classes
    public static SetupAI__Message__c convert(ChatRequest.ChatMessage message, String chatId){
        return new SetupAI__Message__c(SetupAI__Role__c = message.role,
                                       SetupAI__Content__c = message.role == 'system' ? message.content.remove(systemPrompt) : message.content, //Never save custom metadata system prompt
                                       SetupAI__Completion_Tokens__c = message.completionTokens,
                                       SetupAI__Prompt_Tokens__c = message.promptTokens,
                                       SetupAI__Function_Name__c = message.function_call?.name,
                                       SetupAI__Function_Arguments__c = message.function_call?.arguments,
                                       SetupAI__Thread__c = chatId);
    }

}