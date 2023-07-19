/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-19
 * Description: Inserting a Message__c record continues the chat between the user and the AI bot.
*/

trigger MessageTrigger on Message__c (after insert) {
    for(Message__c newMessage : Trigger.new){
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            System.enqueueJob(new MessageTriggerHandler(newMessage));
        }
    }
}