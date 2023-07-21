public with sharing class Controller {
    
    //Creates Chat and System message before inserting first chat message
    @AuraEnabled(cacheable=true)
    public static void initialize(String firstMessage){
        //TODO:
        // - Create Chat record
        // - Call GPT-4 to generate system message
        // - Insert system message
        // - Insert first chat message
    }

}