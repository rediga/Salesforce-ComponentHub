/**
 * @author Rajesh Ediga
 * @description Apex tests for ComponentHub secure services.
 */
@IsTest
private class CH_ComponentHubTest {
    @IsTest
    static void validation_rejectsUnknownComponentType() {
        Boolean hitError = false;
        try {
            CH_ValidationService.assertComponentType('unknownType');
        } catch (CH_ValidationService.ValidationException ex) {
            hitError = true;
        }
        System.assertEquals(true, hitError, 'Unknown component types must be rejected.');
    }

    @IsTest
    static void pagination_clampsPageSize() {
        System.assertEquals(20, CH_PaginationService.normalizePageSize(null));
        System.assertEquals(200, CH_PaginationService.normalizePageSize(5000));
        System.assertEquals(true, CH_PaginationService.hasMore(20, 20));
    }

    @IsTest
    static void metadata_validatesConfigJsonShape() {
        Boolean hitError = false;
        try {
            CH_MetadataService.validateConfigJson('[]');
        } catch (CH_ValidationService.ValidationException ex) {
            hitError = true;
        }
        System.assertEquals(true, hitError, 'Non-object JSON must fail.');

        CH_MetadataService.validateConfigJson('{"id":"accounts","type":"dataTable","props":{}}');
    }

    @IsTest
    static void query_rejectsNonAllowlistedObject() {
        Boolean hitError = false;
        CH_QueryService.QueryRequest request = new CH_QueryService.QueryRequest();
        request.objectApiName = 'User';
        request.fields = new List<String>{ 'Name' };
        request.pageSize = 5;
        try {
            CH_QueryService.queryRecords(request);
        } catch (CH_ValidationService.ValidationException ex) {
            hitError = true;
        }
        System.assertEquals(true, hitError, 'Non-allowlisted objects must be rejected.');
    }

    @IsTest
    static void query_allowlistedAccountPositivePath() {
        Account accountRecord = new Account(Name = 'ComponentHub Test Account');
        insert accountRecord;

        CH_QueryService.QueryRequest request = new CH_QueryService.QueryRequest();
        request.objectApiName = 'Account';
        request.fields = new List<String>{ 'Name' };
        request.whereClause = 'Name = \'ComponentHub Test Account\'';
        request.pageSize = 10;

        Test.startTest();
        CH_QueryService.QueryResult result = CH_QueryService.queryRecords(request);
        Test.stopTest();

        System.assertEquals(1, result.returnedSize);
        System.assertEquals(accountRecord.Id, result.records[0].Id);
    }

    @IsTest
    static void lookup_searchesAllowlistedAccount() {
        insert new Account(Name = 'Lookup Hub Account');

        CH_LookupService.LookupRequest request = new CH_LookupService.LookupRequest();
        request.objectApiName = 'Account';
        request.searchTerm = 'Lookup Hub';
        request.limitSize = 5;

        Test.startTest();
        List<CH_LookupService.LookupOption> options = CH_LookupService.search(request);
        Test.stopTest();

        System.assertEquals(true, !options.isEmpty());
    }

    @IsTest
    static void dml_insertsAllowlistedAccount() {
        CH_DmlService.DmlRequest request = new CH_DmlService.DmlRequest();
        request.objectApiName = 'Account';
        request.operation = 'insert';
        request.fieldValues = new Map<String, Object>{ 'Name' => 'DML Hub Account' };

        Test.startTest();
        Id recordId = CH_DmlService.performDml(request);
        Test.stopTest();

        System.assertNotEquals(null, recordId);
    }

    @IsTest
    static void action_pingAndRejectUnknown() {
        CH_ActionService.ActionRequest pingRequest = new CH_ActionService.ActionRequest();
        pingRequest.actionName = 'ping';
        CH_ActionService.ActionResponse pingResponse = CH_ActionService.execute(pingRequest);
        System.assertEquals(true, pingResponse.success);

        Boolean hitError = false;
        CH_ActionService.ActionRequest badRequest = new CH_ActionService.ActionRequest();
        badRequest.actionName = 'dropDatabase';
        try {
            CH_ActionService.execute(badRequest);
        } catch (CH_ValidationService.ValidationException ex) {
            hitError = true;
        }
        System.assertEquals(true, hitError);
    }

    @IsTest
    static void logging_doesNotThrow() {
        CH_LoggingService.info('test', 'info');
        CH_LoggingService.warn('test', 'warn');
        CH_LoggingService.error('test', 'error', new CH_ValidationService.ValidationException('x'));
        System.assertEquals(true, true);
    }

    @IsTest
    static void metadata_loadsSampleAccountTable() {
        Test.startTest();
        CH_MetadataService.ComponentConfig config =
            CH_MetadataService.getComponentConfig('Sample_Account_Table');
        Test.stopTest();
        System.assertEquals('dataTable', config.componentType);
        System.assertEquals(true, config.isActive);
        System.assertEquals(true, String.isNotBlank(config.configJson));
    }
}
