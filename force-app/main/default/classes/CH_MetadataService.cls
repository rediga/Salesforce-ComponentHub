/**
 * @author Rajesh Ediga
 * @description Loads and validates published ComponentHub configuration from Custom Metadata.
 */
public with sharing class CH_MetadataService {
    public class ComponentConfig {
        @AuraEnabled public String developerName;
        @AuraEnabled public String componentType;
        @AuraEnabled public String configJson;
        @AuraEnabled public String versionNumber;
        @AuraEnabled public Boolean isActive;
    }

    @AuraEnabled(cacheable=true)
    public static ComponentConfig getComponentConfig(String developerName) {
        CH_ValidationService.assertNotBlank(developerName, 'Configuration developer name');

        List<CH_Component_Definition__mdt> rows = [
            SELECT DeveloperName, Component_Type__c, Config_JSON__c, Version__c, Is_Active__c
            FROM CH_Component_Definition__mdt
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];

        if (rows.isEmpty()) {
            throw new CH_ValidationService.ValidationException(
                'No ComponentHub configuration found for: ' + developerName
            );
        }

        CH_Component_Definition__mdt row = rows[0];
        if (row.Is_Active__c != true) {
            throw new CH_ValidationService.ValidationException(
                'ComponentHub configuration is inactive: ' + developerName
            );
        }

        CH_ValidationService.assertComponentType(row.Component_Type__c);
        validateConfigJson(row.Config_JSON__c);

        ComponentConfig config = new ComponentConfig();
        config.developerName = row.DeveloperName;
        config.componentType = row.Component_Type__c;
        config.configJson = row.Config_JSON__c;
        config.versionNumber = row.Version__c;
        config.isActive = row.Is_Active__c;
        return config;
    }

    @AuraEnabled(cacheable=true)
    public static List<ComponentConfig> getActiveConfigs() {
        List<ComponentConfig> results = new List<ComponentConfig>();
        for (CH_Component_Definition__mdt row : [
            SELECT DeveloperName, Component_Type__c, Config_JSON__c, Version__c, Is_Active__c
            FROM CH_Component_Definition__mdt
            WHERE Is_Active__c = TRUE
            ORDER BY DeveloperName
        ]) {
            if (!CH_ValidationService.isAllowedComponentType(row.Component_Type__c)) {
                CH_LoggingService.warn('CH_MetadataService', 'Skipping disallowed type: ' + row.Component_Type__c);
                continue;
            }
            ComponentConfig config = new ComponentConfig();
            config.developerName = row.DeveloperName;
            config.componentType = row.Component_Type__c;
            config.configJson = row.Config_JSON__c;
            config.versionNumber = row.Version__c;
            config.isActive = row.Is_Active__c;
            results.add(config);
        }
        return results;
    }

    public static void validateConfigJson(String configJson) {
        CH_ValidationService.assertNotBlank(configJson, 'Config JSON');
        try {
            Object parsed = JSON.deserializeUntyped(configJson);
            if (!(parsed instanceof Map<String, Object>)) {
                throw new CH_ValidationService.ValidationException('Config JSON must be an object.');
            }
            Map<String, Object> root = (Map<String, Object>) parsed;
            if (!root.containsKey('id') || !root.containsKey('type')) {
                throw new CH_ValidationService.ValidationException('Config JSON requires id and type.');
            }
        } catch (CH_ValidationService.ValidationException ve) {
            throw ve;
        } catch (Exception ex) {
            CH_LoggingService.error('CH_MetadataService', 'Invalid config JSON', ex);
            throw new CH_ValidationService.ValidationException('Config JSON is not valid JSON.');
        }
    }
}
