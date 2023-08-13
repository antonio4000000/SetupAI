/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Interface for OpenAI APIs
*/

public with sharing class OpenAI {
    
    //Send Chat thread and returns generated response
    public static ChatResponse chat(ChatRequest req){
        try{
            return(ChatResponse)JSON.deserialize(Callout.execute(
                /** Named Credential */     'OpenAI_Legacy', 
                /** Endpoint */             'Chat',
                /** Method */               'POST',
                /** Body */                 req.serialize(),
                /** Headers */              new Map<String, String>{
                                                'Content-Type'=>'application/json',
                                                'Authorization'=>'Bearer {!$Credential.Password}'
                                            }
            ).replace('"object":', '"object_x":'),ChatResponse.class);
        }catch(Exception ex){
            return new ChatResponse(
                new ChatRequest.ChatMessage(
                    'error',
                    ex.getMessage()
                )
            );
        }
    }

}