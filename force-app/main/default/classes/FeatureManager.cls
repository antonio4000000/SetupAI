/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-15
 * Description: Interfaces with FeatureParamters to and from PBO
 * Reference:   https://developer.salesforce.com/docs/atlas.en-us.pkg2_dev.meta/pkg2_dev/sfdx_dev_dev2gp_fma_manage_features.htm
*/

public with sharing class FeatureManager {
    
    //-----------------LMO to Subscriber--------------->>>>>

    //Returns true if unlimited license type is subscribed to.
    public static Boolean isUnlimited(){
        return System.FeatureManagement.checkPackageBooleanValue('unlimited');
    }

    //Get total dollar amount token purchases are limited to
    public static Integer tokenLimit(){
        return System.FeatureManagement.checkPackageIntegerValue('tokenSpendLimit');
    }

    //<<<<<------------LMO to Subscriber--------------------

    //-----------------Subscriber to LMO--------------->>>>>

    //Get Input tokens used so far
    public static Integer inputTokens(){
        return System.FeatureManagement.checkPackageIntegerValue('inputTokens');
    }

    //Sets number of inputTokens
    public static void setInputTokens(Integer numberOfTokens){
        System.FeatureManagement.setPackageIntegerValue('inputTokens', numberOfTokens);
    }

    //Get Output tokens used so far
    public static Integer outputTokens(){
        return System.FeatureManagement.checkPackageIntegerValue('outputTokens');
    }

    //Sets number of outputTokens
    public static void setOutputTokens(Integer numberOfTokens){
        System.FeatureManagement.setPackageIntegerValue('outputTokens', numberOfTokens);
    }

    //<<<<<------------Subscriber to LMO--------------------

}