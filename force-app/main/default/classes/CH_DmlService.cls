/**
 * @author Rajesh Ediga
 * @description Authorized DML for ComponentHub with object allowlist and user-mode enforcement.
 */
public with sharing class CH_DmlService {
    public class DmlRequest {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public String operation { get; set; }
        @AuraEnabled public Map<String, Object> fieldValues { get; set; }
        @AuraEnabled public Id recordId { get; set; }
    }

    @AuraEnabled
    public static Id performDml(DmlRequest request) {
        if (request == null) {
            throw new CH_ValidationService.ValidationException('DML request is required.');
        }
        CH_ValidationService.assertNotBlank(request.objectApiName, 'objectApiName');
        CH_ValidationService.assertNotBlank(request.operation, 'operation');
        CH_QueryService.assertObjectAllowed(request.objectApiName);

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(request.objectApiName);
        if (sobjectType == null) {
            throw new CH_ValidationService.ValidationException('Unknown object: ' + request.objectApiName);
        }
        Schema.DescribeSObjectResult describeResult = sobjectType.getDescribe();
        String operation = request.operation.trim().toLowerCase();

        if (operation == 'insert') {
            if (!describeResult.isCreateable()) {
                throw new CH_ValidationService.ValidationException('Create not allowed on ' + request.objectApiName);
            }
            SObject record = sobjectType.newSObject();
            applyWritableFields(record, request.fieldValues, describeResult, true);
            Database.insert(record, AccessLevel.USER_MODE);
            return record.Id;
        }

        if (operation == 'update') {
            if (!describeResult.isUpdateable()) {
                throw new CH_ValidationService.ValidationException('Update not allowed on ' + request.objectApiName);
            }
            if (request.recordId == null) {
                throw new CH_ValidationService.ValidationException('recordId is required for update.');
            }
            SObject record = sobjectType.newSObject(request.recordId);
            applyWritableFields(record, request.fieldValues, describeResult, false);
            Database.update(record, AccessLevel.USER_MODE);
            return record.Id;
        }

        throw new CH_ValidationService.ValidationException('Unsupported DML operation: ' + request.operation);
    }

    private static void applyWritableFields(
        SObject record,
        Map<String, Object> fieldValues,
        Schema.DescribeSObjectResult describeResult,
        Boolean isInsert
    ) {
        if (fieldValues == null || fieldValues.isEmpty()) {
            throw new CH_ValidationService.ValidationException('fieldValues are required.');
        }
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
        for (String fieldName : fieldValues.keySet()) {
            String key = fieldName == null ? null : fieldName.toLowerCase();
            if (key == null || !fieldMap.containsKey(key)) {
                throw new CH_ValidationService.ValidationException('Unknown field: ' + fieldName);
            }
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(key).getDescribe();
            Boolean canWrite = isInsert ? fieldDescribe.isCreateable() : fieldDescribe.isUpdateable();
            if (!canWrite) {
                throw new CH_ValidationService.ValidationException('Field is not writable: ' + fieldName);
            }
            record.put(fieldDescribe.getName(), fieldValues.get(fieldName));
        }
    }
}
