/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Handles inserted Message__c records, continuing the chat.
*/

public with sharing class MessageTriggerHandler implements Queueable, Database.AllowsCallouts {
    
    public class MessageTriggerHandlerException extends Exception{}

    //Message beind handled
    public Message__c newMessage;

    //Constructor
    public MessageTriggerHandler(Message__c newMessage) {
        this.newMessage = newMessage;
    }

    //Execute queueable
    public void execute(QueueableContext context){
        if(!Callout.testSetup){
            try{
                switch on this.newMessage.Role__c {
                    when 'user','function'{
                        //Get entire thread
                        Message__c[] entireThread = [SELECT Role__c, Content__c, Function_Name__c, Function_Arguments__c
                                                    FROM Message__c
                                                    WHERE Thread__c =:this.newMessage.Thread__c
                                                    AND Role__c !=:'error'
                                                    WITH SECURITY_ENFORCED
                                                    ORDER BY Id];
                        //Get AI Response
                        ChatRequest.ChatMessage aiResponse = ChatInterface.chat(
                            MessageConvertor.convert(entireThread),
                            'gpt-3',
                            true
                        );
                        //Check message create permissions
                        if(CRUD.createMessage()){
                            //Insert for next queueable
                            insert MessageConvertor.convert(aiResponse, this.newMessage.Thread__c);
                        }else{
                            throw new MessageTriggerHandlerException(Label.Create_Message_Access);
                        }
                    }
                    when 'assistant','error'{
                        if(this.newMessage.Function_Name__c != null){
                            Function.execute(this.newMessage.Function_Name__c,
                                            this.newMessage.Function_Arguments__c,
                                            this.newMessage.Thread__c);
                        }else if(this.newMessage.Content__c != null && this.newMessage.Content__c != 'null'){
                            Message_Notice__e notice = new Message_Notice__e(MessageId__c = this.newMessage.Id);
                            Database.SaveResult results = EventBus.publish(notice);
                        }
                    }
                }
            }catch(Exception ex){
                Async_Error__e notice = new Async_Error__e(SetupAI__Error_Content__c = ex.getMessage());
                Database.SaveResult results = EventBus.publish(notice);
            }
        }
    }

}