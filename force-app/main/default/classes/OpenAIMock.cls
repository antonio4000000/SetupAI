/* 
 * Author:     Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:    2023-08-07
 * Description:Mocking service for OpenAI callouts
*/

@isTest
public with sharing class OpenAIMock implements HttpCalloutMock {

    //------------------Map requests to responses-------------->>>>>>>>>>
    //User Request: 'Hi there'
    private static Map<String, String> hiThereResponseMap = new Map<String, String>{
        'LabelMaker'=>'{\n    "id":"chatcmpl-7l0t8GPIRPPNoOjIssgUZSQEKDjii",\n    "object":"chat.completion",\n    "created":1691439186,\n    "model":"gpt-3.5-turbo-0613",\n    "choices":[\n        {\n            "index":0,\n            "message":{\n                "role":"assistant",\n                "content":"Chat thread started"\n            },\n            "finish_reason":"stop"\n        }\n    ],\n    "usage":{\n        "prompt_tokens":84,\n        "completion_tokens":3,\n        "total_tokens":87\n    }\n}',
        'SystemPromptHelper'=>'{\n    "id":"chatcmpl-7l1LmtTSj59azb59hgLDIPJgR17kl",\n    "object":"chat.completion",\n    "created":1691440962,\n    "model":"gpt-4-0613",\n    "choices":[\n        {\n            "index":0,\n            "message":{\n                "role":"assistant",\n                "content":"Just say hi and ask the end user how you can help them today"\n            },\n            "finish_reason":"stop"\n        }\n    ],\n    "usage":{\n        "prompt_tokens":1834,\n        "completion_tokens":13,\n        "total_tokens":1847\n    }\n}',
        'Conversation'=>'{"id":"chatcmpl-7l1TcHKRVSXyTzSRQof2BvUDTLMoI","object":"chat.completion","created":1691441448,"model":"gpt-3.5-turbo-0613","choices":[{"index":0,"message":{"role":"assistant","content":"Hello! How can I help you today?"},"finish_reason":"stop"}],"usage":{"prompt_tokens":1122,"completion_tokens":10,"total_tokens":1132}}'
    };
    //User Request: 'Thank you very much'(continuing after info)
    private static Map<String, String> thankYouResponseMap = new Map<String, String>{
        'Conversation'=>'{"id": "chatcmpl-7l27kXhSQLd6DVel9iLGmxZ87JO3x","object": "chat.completion","created": 1691443936,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "You\'re welcome! If you have any more questions, feel free to ask."},"finish_reason": "stop"}],"usage": {"prompt_tokens": 1393,"completion_tokens": 17,"total_tokens": 1410}}'
    };
    //User Request: 'What is my user Id?'
    private static Map<String, String> userIdMap = new Map<String, String>{
        'FunctionCall'=>'{"id": "chatcmpl-7lg516RmuH6P3SKvCtEhrecnUQy1L","object": "chat.completion","created": 1691597527,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": null,"function_call": {"name": "getUserId","arguments": "{}"}},"finish_reason": "function_call"}],"usage": {"prompt_tokens": 1115,"completion_tokens": 6,"total_tokens": 1121}}',
        'Conversation'=>'{"id": "chatcmpl-7lg6OQFPDOdC5a4yjXDtDx1g7KedK","object": "chat.completion","created": 1691597612,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "Your user Id is ' + UserInfo.getUserId() + '."},"finish_reason": "stop"}],"usage": {"prompt_tokens": 1138,"completion_tokens": 16,"total_tokens": 1154}}'
    };
    //User Request: 'What is the Account number of the account named 'Test Account'?'
    private static Map<String, String> accountNumberMap = new Map<String, String>{
        'Conversation'=>'{"id": "chatcmpl-7lgstzUUVv7LzCw0YAQwF7aE1lL7J","object": "chat.completion","created": 1691600619,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "The Account number of the account named \'Test Account\' is 1234."},"finish_reason": "stop"}],"usage": {"prompt_tokens": 1224,"completion_tokens": 17,"total_tokens": 1241}}'
    };
    //User Request: 'Summarize the MessageTriggerHandler Apex class'
    private static Map<String, String> apexClassMap = new Map<String, String>{
        'Conversation'=>'{"id": "chatcmpl-7m6E02cQ7KB2ElWpx2EBEt2vkg2th","object": "chat.completion","created": 1691698028,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "The MessageTriggerHandler Apex class is a public class that implements the Queueable and Database.AllowsCallouts interfaces. It is responsible for handling inserted Message__c records and continuing the chat. Here are some key points about the class:  - The class has an inner class called MessageTriggerHandlerException, which extends the Exception class. - The class has a variable called newMessage of type Message__c, which represents the message being handled. - The class has a constructor that takes a Message__c parameter and assigns it to the newMessage variable. - The class implements the execute method from the Queueable interface, which is responsible for executing the logic in a separate queueable job. - Inside the execute method, there is a switch statement based on the Role__c field of the newMessage. Depending on the role, different actions are taken. - If the role is \'user\' or \'function\', the class retrieves the entire thread of messages related to the newMessage, using a SOQL query. It then calls a ChatInterface to get an AI response based on the entire thread. If the user has create permissions for messages, a new message is inserted based on the AI response. - If the role is \'assistant\' or \'error\', the class checks if there is a Function_Name__c specified in the newMessage. If so, it calls a Function.execute method with the function name and arguments. If not, it checks if there is a Content__c specified in the newMessage and it is not null. If so, it creates a Message_Notice__e event and publishes it using the EventBus. - If any exception occurs during the execution, an Async_Error__e event is created with the error message and the Chat_Id__c, and it is published using the EventBus.  Overall, the MessageTriggerHandler class handles the logic for continuing the chat based on the role of the message and performs various actions like retrieving the entire thread, calling AI services, executing functions, and publishing events."},"finish_reason": "stop"}],"usage": {"prompt_tokens": 2018,"completion_tokens": 405,"total_tokens": 2423}}'
    };
    //User Request: 'What objects are accessible to me through the Tooling API?'
    private static Map<String, String> toolingObjectsMap = new Map<String, String>{
        'Conversation'=>'{"id": "chatcmpl-7m7AaHYfiyYHPzzJgaFXyw05EpJrH","object": "chat.completion","created": 1691701660,"model": "gpt-3.5-turbo-0613","choices": [{"index": 0,"message": {"role": "assistant","content": "The objects accessible to you through the Tooling API are:  - AIApplication - AIApplicationConfig - AIReplyRecommendationsSettings - AccessControlPolicy - AccountInsightsSettings - AccountIntelligenceSettings - AccountSettings - ActionsSettings - ActivitiesSettings - AddressSettings - AdjustmentsSettings - AnalyticsSettings - AnimationRule - ApexClass - ApexClassMember - ApexCodeCoverage - ApexCodeCoverageAggregate - ApexComponent - ApexComponentMember - ApexDebuggerSession - ApexEmailNotification - ApexExecutionOverlayAction - ApexExecutionOverlayResult - ApexLog - ApexOrgWideCoverage - ApexPage - ApexPageInfo - ApexPageMember - ApexSettings - ApexTestQueueItem - ApexTestResult - ApexTestResultLimits - ApexTestRunResult - ApexTestSuite - ApexTrigger - ApexTriggerMember - AppAnalyticsSettings - AppExperienceSettings - ArchiveSettings - AssignmentRule - AsyncApexJob - AuraDefinition - AuraDefinitionBundle - AuraDefinitionChange - AutoResponseRule - AutomatedContactsSettings - BlockchainSettings - BrandingSet - BrandingSetProperty - BriefcaseDefinition - BusinessHoursEntry - BusinessHoursSettings - BusinessProcess - CampaignInfluenceModel - CampaignSettings - CaseSettings - Certificate - ChannelLayout - ChatterAnswersSettings - ChatterEmailsMDSettings - ChatterSettings - CleanDataService - CleanRule - CodeBuilderSettings - ColorDefinition - CommerceSettings - CommunitiesSettings - CompactLayout - CompactLayoutInfo - CompactLayoutItemInfo - CompanySettings - ConnectedAppSettings - ConnectedApplication - ContainerAsyncRequest - ContentSettings - ContractSettings - ConversationalIntelligenceSettings - CountriesAndStates - Country - CspTrustedSite - CurrencySettings - CustomAddressFieldSettings - CustomApplication - CustomField - CustomFieldMember - CustomHelpMenuSection - CustomHttpHeader - CustomNotificationType - CustomObject - CustomTab - CustomerDataPlatformSettings - CustomizablePropensityScoringSettings - DashboardMobileSettings - DataAssessmentConfigItem - DataDotComEntitySetting - DataDotComSettings - DataType - DebugLevel - DeployRequest - DeployTestResult - DeploymentSettings - DevHubSettings - DiscoverySettings - Document - DocumentChecklistSettings - DomainProvision - DynamicFormsSettings - EACSettings - EinsteinAgentSettings - EinsteinAssistantSettings - EinsteinDealInsightsSettings - EinsteinDocumentCaptureSettings - EmailAdministrationSettings - EmailIntegrationSettings - EmailTemplate - EmailTemplateSettings - EmailToCaseRoutingAddress - EmailToCaseSettings - EmbeddedServiceAppointmentSettings - EmbeddedServiceBranding - EmbeddedServiceConfig - EmbeddedServiceCustomComponent - EmbeddedServiceCustomLabel - EmbeddedServiceCustomization - EmbeddedServiceFlow - EmbeddedServiceFlowConfig - EmbeddedServiceLayout - EmbeddedServiceLayoutRule - EmbeddedServiceMenuItem - EmbeddedServiceMenuSettings - EmbeddedServiceResource - EmployeeFieldAccessSettings - EmployeeUserSettings - EncryptionKeySettings - EnhancedNotesSettings - EnrichedField - EntitlementSettings - EntityDefinition - EntityLimit - EntityParticle - EssentialsSettings - EventRelayConfig - EventSettings - ExternalCredential - ExternalCredentialParameter - ExternalDataSource - ExternalDataSrcDescriptor - ExternalServiceRegistration - ExternalString - FeedItemSettings - FieldDefinition - FieldMapping - FieldMappingField - FieldMappingRow - FieldRestrictionRule - FieldServiceSettings - FieldSet - FileTypeDispositionAssignmentBean - FileUploadAndDownloadSecuritySettings - FilesConnectSettings - FindSimilarOppFilter - FlexiPage - Flow - FlowCategory - FlowDefinition - FlowElementTestCoverage - FlowSettings - FlowTest - FlowTestCoverage - ForecastRangeSettings - ForecastingDisplayedFamilySettings - ForecastingObjectListSelectedSettings - ForecastingObjectListSettings - ForecastingSettings - ForecastingTypeSettings - FormulaFunction - FormulaFunctionAllowedType - FormulaFunctionCategory - FormulaOperator - FormulaSettings - FormulaVariable - GlobalValueSet - GoogleAppsSettings - Group - GtwyProvPaymentMethodType - HighVelocitySalesSettings - HomePageComponent - HomePage"},"finish_reason": "length"}],"usage": {"prompt_tokens": 3146,"completion_tokens": 951,"total_tokens": 4097}}'
    };

    //------------------Map requests to responses------------------------
    
    //Handle callout
    public HttpResponse respond(HttpRequest req){
        //If tooling call, return immmediately
        if(req.getEndpoint().contains(ToolingAPI.getEndpoint('Tooling'))) return ToolingAPIMock.getToolingResponse(req);
        //Generate OpanAI Response
        HttpResponse response = new HttpResponse();
        response.setBody(
            getResponseBody(
                /* Request Body */  req.getBody(), 
                /* Mappings*/       req.getBody().contains('Hi there') ? hiThereResponseMap :
                                    req.getBody().contains('Thank you very much') ? thankYouResponseMap : 
                                    req.getBody().contains('What is my user Id?') ? userIdMap : 
                                    req.getBody().contains('What is the Account number of the account named \'Test Account\'?') ? accountNumberMap : 
                                    req.getBody().contains('Summarize the MessageTriggerHandler Apex class') ? apexClassMap : 
                                    req.getBody().contains('What objects are accessible to me through the Tooling API?') ? toolingObjectsMap : 
                                    new Map<String, String>{}
            )
        );
        response.setStatusCode(200);
        response.setStatus('success');
        return response;
    }

    //Get response for a given request
    private static String getResponseBody(String body, Map<String, String> responseMap){
        return body.contains('You are a Salesforce chatbot label maker.') ? responseMap.get('LabelMaker') :
               body.contains('A Salesforce admin is asking another chatbot a question about their Salesforce org.') ? responseMap.get('SystemPromptHelper') :
               body.contains('"functions":') ? 
                    !body.contains('"role":"function"') && body.contains('"function_call":') ?
                    responseMap.get('FunctionCall') :
                    responseMap.get('Conversation') :
               null;
    }
    
    
}