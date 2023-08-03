FunctionParam.metadataDrilldown md = new FunctionParam.metadataDrilldown();
md.path = 'actionOverrides';
md.toolingQuery = 'SELECT Metadata FROM EntityDefinition WHERE QualifiedApiName = \'SetupAI__Chat__c\'';
System.debug(Function.metadataDrilldown(md));