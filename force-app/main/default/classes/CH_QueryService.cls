/**
 * @author Rajesh Ediga
 * @description Allowlisted, FLS-aware query service for ComponentHub.
 */
public with sharing class CH_QueryService {
    public class QueryRequest {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public List<String> fields { get; set; }
        @AuraEnabled public String whereClause { get; set; }
        @AuraEnabled public String orderByField { get; set; }
        @AuraEnabled public String orderDirection { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        @AuraEnabled public String lastSeenId { get; set; }
    }

    public class QueryResult {
        @AuraEnabled public List<SObject> records;
        @AuraEnabled public Integer returnedSize;
        @AuraEnabled public String nextLastSeenId;
        @AuraEnabled public Boolean hasMore;
    }

    @AuraEnabled
    public static QueryResult queryRecords(QueryRequest request) {
        if (request == null) {
            throw new CH_ValidationService.ValidationException('Query request is required.');
        }
        CH_ValidationService.assertNotBlank(request.objectApiName, 'objectApiName');
        assertObjectAllowed(request.objectApiName);

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(request.objectApiName);
        if (sobjectType == null) {
            throw new CH_ValidationService.ValidationException('Unknown object: ' + request.objectApiName);
        }
        Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe();
        if (!describeResult.isAccessible()) {
            throw new CH_ValidationService.ValidationException('Object is not accessible: ' + request.objectApiName);
        }

        List<String> safeFields = sanitizeFields(request.fields, describeResult);
        Integer pageSize = CH_ValidationService.clampPageSize(request.pageSize, 20, 200);
        String orderByField = sanitizeOrderBy(request.orderByField, describeResult);
        String orderDirection = 'DESC'.equalsIgnoreCase(request.orderDirection) ? 'DESC' : 'ASC';

        String soql =
            'SELECT ' +
            String.join(safeFields, ',') +
            ' FROM ' +
            String.escapeSingleQuotes(request.objectApiName);

        List<String> filters = new List<String>();
        if (String.isNotBlank(request.whereClause)) {
            // Only allow a narrow, pre-validated equality filter shape: FieldApiName = 'literal'
            filters.add(sanitizeSimpleEqualsFilter(request.whereClause, describeResult));
        }
        if (String.isNotBlank(request.lastSeenId)) {
            filters.add('Id > :lastSeenId');
        }
        if (!filters.isEmpty()) {
            soql += ' WHERE ' + String.join(filters, ' AND ');
        }
        soql += ' ORDER BY ' + orderByField + ' ' + orderDirection + ', Id ASC LIMIT :pageSize';

        Id lastSeenId = String.isBlank(request.lastSeenId) ? null : (Id) request.lastSeenId;
        List<SObject> records = Database.query(soql, AccessLevel.USER_MODE);

        QueryResult result = new QueryResult();
        result.records = records;
        result.returnedSize = records.size();
        result.hasMore = records.size() == pageSize;
        result.nextLastSeenId = records.isEmpty() ? null : (String) records[records.size() - 1].get('Id');
        return result;
    }

    public static void assertObjectAllowed(String objectApiName) {
        List<CH_Object_Allowlist__mdt> allowlist = [
            SELECT Object_API_Name__c
            FROM CH_Object_Allowlist__mdt
            WHERE Is_Active__c = TRUE AND Object_API_Name__c = :objectApiName
            LIMIT 1
        ];
        if (allowlist.isEmpty()) {
            throw new CH_ValidationService.ValidationException(
                'Object is not allowlisted for ComponentHub queries: ' + objectApiName
            );
        }
    }

    private static List<String> sanitizeFields(List<String> requestedFields, Schema.DescribeSObjectResult describeResult) {
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        Set<String> selected = new Set<String>{ 'Id' };
        if (requestedFields != null) {
            for (String fieldName : requestedFields) {
                if (String.isBlank(fieldName)) {
                    continue;
                }
                String trimmed = fieldName.trim();
                String key = trimmed.toLowerCase();
                if (!fieldMap.containsKey(key)) {
                    throw new CH_ValidationService.ValidationException('Unknown field: ' + trimmed);
                }
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(key).getDescribe();
                if (!fieldDescribe.isAccessible()) {
                    throw new CH_ValidationService.ValidationException('Field is not accessible: ' + trimmed);
                }
                selected.add(fieldDescribe.getName());
            }
        }
        return new List<String>(selected);
    }

    private static String sanitizeOrderBy(String orderByField, Schema.DescribeSObjectResult describeResult) {
        if (String.isBlank(orderByField)) {
            return 'Id';
        }
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        String key = orderByField.toLowerCase();
        if (!fieldMap.containsKey(key)) {
            throw new CH_ValidationService.ValidationException('Invalid orderBy field: ' + orderByField);
        }
        if (!fieldMap.get(key).getDescribe().isAccessible()) {
            throw new CH_ValidationService.ValidationException('orderBy field is not accessible: ' + orderByField);
        }
        return fieldMap.get(key).getDescribe().getName();
    }

    /**
     * Accepts only Field = 'value' or Field = null. Rejects SOQL injection patterns.
     */
    private static String sanitizeSimpleEqualsFilter(String whereClause, Schema.DescribeSObjectResult describeResult) {
        String trimmed = whereClause.trim();
        Pattern equalsPattern = Pattern.compile('(?i)^([A-Za-z0-9_]+)\\s*=\\s*(null|\'[^\']*\')$');
        Matcher matcher = equalsPattern.matcher(trimmed);
        if (!matcher.matches()) {
            throw new CH_ValidationService.ValidationException(
                'whereClause must be a simple Field = \'value\' or Field = null expression.'
            );
        }
        String fieldName = matcher.group(1);
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        String key = fieldName.toLowerCase();
        if (!fieldMap.containsKey(key)) {
            throw new CH_ValidationService.ValidationException('Unknown whereClause field: ' + fieldName);
        }
        if (!fieldMap.get(key).getDescribe().isAccessible()) {
            throw new CH_ValidationService.ValidationException('whereClause field is not accessible: ' + fieldName);
        }
        String resolvedField = fieldMap.get(key).getDescribe().getName();
        String rhs = matcher.group(2);
        if ('null'.equalsIgnoreCase(rhs)) {
            return resolvedField + ' = null';
        }
        return resolvedField + ' = ' + rhs;
    }
}
