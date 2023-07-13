FunctionParam.describeDrilldown fp = new FunctionParam.describeDrilldown();
fp.object_x = 'ApexClass';
fp.path = 'childRelationships';
System.debug(Function.describeDrilldown(fp));