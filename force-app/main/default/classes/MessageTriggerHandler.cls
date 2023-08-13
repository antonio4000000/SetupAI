/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Handles inserted Message__c records, continuing the chat.
*/

public with sharing class MessageTriggerHandler implements Queueable, Database.AllowsCallouts {
    
    public class MessageTriggerHandlerException extends Exception{}

    //Cache platform events for test coverage
    public static SetupAI__Async_Error__e[] asyncErrorsPublished = new SetupAI__Async_Error__e[]{};

    //Message beind handled
    public SetupAI__Message__c newMessage;

    //Constructor
    public MessageTriggerHandler(SetupAI__Message__c newMessage) {
        this.newMessage = newMessage;
    }

    //Execute queueable
    public void execute(QueueableContext context){
        if(!Callout.testSetup){
            try{
                switch on this.newMessage.SetupAI__Role__c {
                    when 'user','function'{
                        //Get entire thread
                        SetupAI__Message__c[] entireThread = [SELECT SetupAI__Role__c, SetupAI__Content__c, SetupAI__Function_Name__c, SetupAI__Function_Arguments__c
                                                              FROM SetupAI__Message__c
                                                              WHERE SetupAI__Thread__c =:this.newMessage.Thread__c
                                                              AND SetupAI__Role__c !=:'error'
                                                              WITH SECURITY_ENFORCED
                                                              ORDER BY Name];
                        //Get AI Response
                        ChatRequest.ChatMessage aiResponse = ChatInterface.chat(
                            MessageConvertor.convert(entireThread),
                            'gpt-3',
                            true
                        );
                        //Check message create permissions
                        if(CRUD.createMessage()){
                            //Insert for next queueable
                            insert MessageConvertor.convert(aiResponse, this.newMessage.SetupAI__Thread__c);
                        }else{
                            throw new MessageTriggerHandlerException(Label.Create_Message_Access);
                        }
                    }
                    when 'assistant','error'{
                        if(this.newMessage.SetupAI__Function_Name__c != null){
                            Function.execute(this.newMessage.SetupAI__Function_Name__c,
                                             this.newMessage.SetupAI__Function_Arguments__c,
                                             this.newMessage.SetupAI__Thread__c);
                        }else if(this.newMessage.SetupAI__Content__c != null && this.newMessage.SetupAI__Content__c != 'null'){
                            SetupAI__Message_Notice__e notice = new SetupAI__Message_Notice__e(Chat_Id__c = this.newMessage.SetupAI__Thread__c);
                            Database.SaveResult results = EventBus.publish(notice);
                        }
                    }
                    when else{
                        throw new MessageTriggerHandlerException(Label.Unexpected_Role);
                    }
                }
            }catch(Exception ex){
                SetupAI__Async_Error__e notice = new Async_Error__e(SetupAI__Error_Content__c = ex.getMessage(),
                                                                    SetupAI__Chat_Id__c = this.newMessage.SetupAI__Thread__c);
                Database.SaveResult results = EventBus.publish(notice);
                asyncErrorsPublished.add(notice);
            }
        }
    }

}