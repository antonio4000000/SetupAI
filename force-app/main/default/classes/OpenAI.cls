/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interface for OpenAI APIs
*/

public with sharing class OpenAI {

    public class OpenAIException extends Exception{}
    
    //Send Chat thread and returns generated response
    public static ChatResponse chat(ChatRequest req){
        try{
            if(Tokenizer.maxExceeded()){
                throw new OpenAIException(Label.Max_Tokens_Exceeded);
            }
            String response;
            do{
                response = Callout.execute(
                    /** Endpoint */             'Chat',
                    /** Method */               'POST',
                    /** Body */                 req.serialize(),
                    /** Headers */              new Map<String, String>{
                                                    'Content-Type'=>'application/json',
                                                    'Authorization'=>'Bearer '+CalloutSecurity.getOpenAIKey()
                                                }
                ).replace('"object":', '"object_x":');
            }while(response == 'RETRY');
            //If backup key was flipped, save to custom setting(doing after all callouts to avoid uncommitted work error)
            if(Callout.useBackup){
                CalloutSecurity.setBackupKeyTrue();
            }
            return(ChatResponse)JSON.deserialize(response, ChatResponse.class);
        }catch(Exception ex){
            return getError(ex.getMessage());
        }
    }

    //Format error message in chat
    public static ChatResponse getError(String errorMessage){
        return new ChatResponse(
            new ChatRequest.ChatMessage(
                'error',
                errorMessage
            )
        );
    }

}