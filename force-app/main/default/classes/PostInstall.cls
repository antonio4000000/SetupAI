/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-14
 * Description: Post-install script creates first custom metadata record upon installation.
*/

public class PostInstall implements InstallHandler {
    
    //Create default custom setting if it doesn't exist
    public void onInstall(InstallContext context){
        if(SetupAI__Token_Usage__c.getOrgDefaults() != null){
            SetupAI__Token_Usage__c usage = new SetupAI__Token_Usage__c();
            usage.SetupOwnerId = UserInfo.getOrganizationId();
            usage.SetupAI__Month__c = Date.today().month();
            upsert usage;
        }
    }

}