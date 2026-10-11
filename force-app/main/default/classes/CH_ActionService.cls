/**
 * @author Rajesh Ediga
 * @description Named, allowlisted actions for ComponentHub (no arbitrary Apex invocation).
 */
public with sharing class CH_ActionService {
    public class ActionRequest {
        @AuraEnabled public String actionName { get; set; }
        @AuraEnabled public Map<String, Object> params { get; set; }
    }

    public class ActionResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public Object payload;
    }

    private static final Set<String> ALLOWED_ACTIONS = new Set<String>{
        'refreshConfig',
        'ping'
    };

    @AuraEnabled
    public static ActionResponse execute(ActionRequest request) {
        ActionResponse response = new ActionResponse();
        if (request == null || String.isBlank(request.actionName)) {
            throw new CH_ValidationService.ValidationException('actionName is required.');
        }
        String actionName = request.actionName.trim();
        if (!ALLOWED_ACTIONS.contains(actionName)) {
            throw new CH_ValidationService.ValidationException('Action is not allowlisted: ' + actionName);
        }

        if (actionName == 'ping') {
            response.success = true;
            response.message = 'ComponentHub action service is healthy.';
            response.payload = Datetime.now();
            return response;
        }

        if (actionName == 'refreshConfig') {
            String developerName =
                request.params == null ? null : (String) request.params.get('developerName');
            CH_MetadataService.ComponentConfig config = CH_MetadataService.getComponentConfig(developerName);
            response.success = true;
            response.message = 'Configuration loaded.';
            response.payload = config;
            return response;
        }

        response.success = false;
        response.message = 'Unhandled allowlisted action.';
        return response;
    }
}
