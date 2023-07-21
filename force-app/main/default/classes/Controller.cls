/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-21
 * Description: Controller for LWC user interface for chat
*/

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