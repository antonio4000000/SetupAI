/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-11-15
 * Description: Interfaces with FeatureParamters to and from PBO
 * Reference:   https://developer.salesforce.com/docs/atlas.en-us.pkg2_dev.meta/pkg2_dev/sfdx_dev_dev2gp_fma_manage_features.htm
*/

public with sharing class FeatureManager {

    //-----------------Internal------------------------>>>>>

    //Returns true if permission set
    public static Boolean hasSetupAIAccess(){
        return FeatureManagement.checkPermission('SetupAI__SetupAI');
    }

    //<<<<<------------Internal-----------------------------
    
    //-----------------LMO to Subscriber--------------->>>>>

    //Get total dollar amount token purchases are limited to
    public static Integer tokenLimit(){
        return System.FeatureManagement.checkPackageIntegerValue('tokenSpendLimit');
    }

    //Get cost of input tokens
    public static Integer inputTokenCost(){
        return System.FeatureManagement.checkPackageIntegerValue('inputTokenCost');
    }

    //Get cost of output tokens
    public static Integer outputTokenCost(){
        return System.FeatureManagement.checkPackageIntegerValue('outputTokenCost');
    }

    //<<<<<------------LMO to Subscriber--------------------

    //-----------------Subscriber to LMO--------------->>>>>

    //Get Input tokens used so far
    public static Integer inputTokens(){
        return System.FeatureManagement.checkPackageIntegerValue('inputTokens');
    }

    //Sets number of inputTokens
    @future
    public static void setInputTokens(Integer numberOfTokens){
        if(!Test.isRunningTest()){System.FeatureManagement.setPackageIntegerValue('inputTokens', numberOfTokens);}
    }

    //Get Output tokens used so far
    public static Integer outputTokens(){
        return System.FeatureManagement.checkPackageIntegerValue('outputTokens');
    }

    //Sets number of outputTokens
    @future
    public static void setOutputTokens(Integer numberOfTokens){
        if(!Test.isRunningTest()){System.FeatureManagement.setPackageIntegerValue('outputTokens', numberOfTokens);}
    }

    //Returns value for usingCustomAPIKey
    public static Boolean usingCustomAPIKey(){
        return System.FeatureManagement.checkPackageBooleanValue('usingCustomAPIKey');
    }

    //Sets number of outputTokens
    @future
    public static void setUsingCustomAPIKey(Boolean newValue){
        System.FeatureManagement.setPackageBooleanValue('usingCustomAPIKey', newValue);
    }

    //<<<<<------------Subscriber to LMO--------------------

    public static Double amountSpent(){
        return ((inputTokens()/1000) * (.0001*inputTokenCost())) +
               ((outputTokens()/1000) * (.0001*outputTokenCost()));
    }

}