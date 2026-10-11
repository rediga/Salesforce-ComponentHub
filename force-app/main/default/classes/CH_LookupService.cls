/**
 * @author Rajesh Ediga
 * @description Bounded lookup search for ComponentHub with allowlisted objects/fields.
 */
public with sharing class CH_LookupService {
    public class LookupRequest {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String searchTerm { get; set; }
        @AuraEnabled public String nameField { get; set; }
        @AuraEnabled public Integer limitSize { get; set; }
    }

    public class LookupOption {
        @AuraEnabled public Id id;
        @AuraEnabled public String label;
    }

    @AuraEnabled
    public static List<LookupOption> search(LookupRequest request) {
        if (request == null) {
            throw new CH_ValidationService.ValidationException('Lookup request is required.');
        }
        CH_ValidationService.assertNotBlank(request.objectApiName, 'objectApiName');
        CH_QueryService.assertObjectAllowed(request.objectApiName);

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(request.objectApiName);
        if (sobjectType == null) {
            throw new CH_ValidationService.ValidationException('Unknown object: ' + request.objectApiName);
        }
        Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe();
        if (!describeResult.isAccessible() || !describeResult.isSearchable()) {
            throw new CH_ValidationService.ValidationException(
                'Object is not searchable/accessible: ' + request.objectApiName
            );
        }

        String nameField = String.isBlank(request.nameField) ? 'Name' : request.nameField.trim();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        String nameKey = nameField.toLowerCase();
        if (!fieldMap.containsKey(nameKey) || !fieldMap.get(nameKey).getDescribe().isAccessible()) {
            throw new CH_ValidationService.ValidationException('Lookup name field is not accessible: ' + nameField);
        }
        String resolvedNameField = fieldMap.get(nameKey).getDescribe().getName();
        Integer limitSize = CH_ValidationService.clampPageSize(request.limitSize, 10, 25);

        String term = String.isBlank(request.searchTerm) ? '%' : '%' + String.escapeSingleQuotes(request.searchTerm.trim()) + '%';
        String soql =
            'SELECT Id, ' +
            resolvedNameField +
            ' FROM ' +
            String.escapeSingleQuotes(request.objectApiName) +
            ' WHERE ' +
            resolvedNameField +
            ' LIKE :term ORDER BY ' +
            resolvedNameField +
            ' ASC LIMIT :limitSize';

        List<LookupOption> options = new List<LookupOption>();
        for (SObject record : Database.query(soql, AccessLevel.USER_MODE)) {
            LookupOption option = new LookupOption();
            option.id = (Id) record.get('Id');
            option.label = String.valueOf(record.get(resolvedNameField));
            options.add(option);
        }
        return options;
    }
}
