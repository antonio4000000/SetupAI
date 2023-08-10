/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-10
 * Description: Mocking service for ToolingAPI callouts(don't set in test classes as mock. Set OpanAI mock and this will be called from there.)
*/

public with sharing class ToolingAPIMock {

    public static Map<String, String> responseMap = new Map<String,String>{
        'MessageTriggerHandler'=>'{\"size\":1,\"totalSize\":1,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"ApexClass\",\"records\":[{\"attributes\":{\"type\":\"ApexClass\",\"url\":\"/services/data/v56.0/tooling/sobjects/ApexClass/01p7i00000PU3yZAAT\"},\"Name\":\"MessageTriggerHandler\",\"Body\":\"/* \\n * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)\\n * Created:     2023-07-19\\n * Description: Handles inserted Message__c records, continuing the chat.\\n*/\\n\\npublic with sharing class MessageTriggerHandler implements Queueable, Database.AllowsCallouts {\\n    \\n    public class MessageTriggerHandlerException extends Exception{}\\n\\n    //Message beind handled\\n    public Message__c newMessage;\\n\\n    //Constructor\\n    public MessageTriggerHandler(Message__c newMessage) {\\n        this.newMessage = newMessage;\\n    }\\n\\n    //Execute queueable\\n    public void execute(QueueableContext context){\\n        if(!Callout.testSetup){\\n            try{\\n                switch on this.newMessage.Role__c {\\n                    when \'user\',\'function\'{\\n                        //Get entire thread\\n                        Message__c[] entireThread = [SELECT Role__c, Content__c, Function_Name__c, Function_Arguments__c\\n                                                    FROM Message__c\\n                                                    WHERE Thread__c =:this.newMessage.Thread__c\\n                                                    AND Role__c !=:\'error\'\\n                                                    WITH SECURITY_ENFORCED\\n                                                    ORDER BY Name];\\n                        //Get AI Response\\n                        ChatRequest.ChatMessage aiResponse = ChatInterface.chat(\\n                            MessageConvertor.convert(entireThread),\\n                            \'gpt-3\',\\n                            true\\n                        );\\n                        //Check message create permissions\\n                        if(CRUD.createMessage()){\\n                            //Insert for next queueable\\n                            insert MessageConvertor.convert(aiResponse, this.newMessage.Thread__c);\\n                        }else{\\n                            throw new MessageTriggerHandlerException(Label.Create_Message_Access);\\n                        }\\n                    }\\n                    when \'assistant\',\'error\'{\\n                        if(this.newMessage.Function_Name__c != null){\\n                            Function.execute(this.newMessage.Function_Name__c,\\n                                            this.newMessage.Function_Arguments__c,\\n                                            this.newMessage.Thread__c);\\n                        }else if(this.newMessage.Content__c != null && this.newMessage.Content__c != \'null\'){\\n                            Message_Notice__e notice = new Message_Notice__e(Chat_Id__c = this.newMessage.Thread__c);\\n                            Database.SaveResult results = EventBus.publish(notice);\\n                        }\\n                    }\\n                }\\n            }catch(Exception ex){\\n                Async_Error__e notice = new Async_Error__e(SetupAI__Error_Content__c = ex.getMessage(),\\n                                                           Chat_Id__c = this.newMessage.Thread__c);\\n                Database.SaveResult results = EventBus.publish(notice);\\n            }\\n        }\\n    }\\n\\n}\"}]}'
    };
    

    //Handle Tooling API calls
    public static HttpResponse getToolingResponse(HttpRequest req){
        HttpResponse response = new HttpResponse();
        response.setBody(
            req.getEndpoint().contains('MessageTriggerHandler') ? responseMap.get('MessageTriggerHandler') : ''
        );
        response.setStatusCode(200);
        response.setStatus('success');
        return response;
    }

}