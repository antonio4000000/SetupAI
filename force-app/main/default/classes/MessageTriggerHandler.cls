/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Handles inserted Message__c records, continuing the chat.
*/

public with sharing class MessageTriggerHandler implements Queueable, Database.AllowsCallouts {
    
    //Message beind handled
    public Message__c newMessage;

    //Constructor
    public MessageTriggerHandler(Message__c newMessage) {
        this.newMessage = newMessage;
    }

    //Execute queueable
    public void execute(QueueableContext context){
        switch on this.newMessage.Role__c {
            when 'user','function'{
                //Get entire thread
                Message__c[] entireThread = [SELECT Role__c, Content__c, Function_Name__c, Function_Arguments__c
                                             FROM Message__c
                                             WHERE Thread__c =:this.newMessage.Thread__c
                                             AND Role__c !=:'error'
                                             ORDER BY Name];
                //Get AI Response
                ChatRequest.ChatMessage aiResponse = ChatInterface.chat(
                    MessageConvertor.convert(entireThread),
                    'gpt-3'
                );
                //Insert for next queueable
                insert MessageConvertor.convert(aiResponse);
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
    }

}