public with sharing class OpenAI {
    
    //Send Chat thread and returns generated response
    public static ChatResponse chat(ChatRequest req){
        try{
            return(ChatResponse)JSON.deserialize(Callout.execute(
                /** Named Credential */     'OpenAI', 
                /** Endpoint */             'Chat',
                /** Method */               'POST',
                /** Body */                 req.serialize(),
                /** Headers */              new Map<String, String>{'Content-Type'=>'application/json'}
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