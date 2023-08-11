/*
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-08-11
 * Description: Test Coverage for JSONHelper.cls and Utils.cls
 */

@isTest
public with sharing class TestJSONHelper {
    
    //Test getting JSON value
    @isTest
    static void testGetJSONValue(){
        //Setup test
        String example = '{"testObject":{"fieldOne":true,"fieldTwo":"Hi there","fieldThree":4321,"listField":[1,2,3,4]}}';
        
        //Run test
        Test.startTest();
        String boolVal = JSONHelper.getJSONValue(example, 'testObject.fieldOne');
        String stringVal = JSONHelper.getJSONValue(example, 'testObject.fieldTwo');
        String numVal = JSONHelper.getJSONValue(example, 'testObject.fieldThree');
        String listVal = JSONHelper.getJSONValue(example, 'testObject.listField');
        Test.stopTest();

        //Verify results
        System.assertEquals('true', boolVal, 'Unexpected value returned in JSON');
        System.assertEquals('"Hi there"', stringVal, 'Unexpected value returned in JSON');
        System.assertEquals('4321', numVal, 'Unexpected value returned in JSON');
        System.assertEquals('[1,2,3,4]', listVal, 'Unexpected value returned in JSON');
    }

}