/**
 * @author Rajesh Ediga
 * @description Server-side validation for ComponentHub configuration and inputs.
 */
public with sharing class CH_ValidationService {
    public class ValidationException extends Exception {
    }

    private static final Set<String> ALLOWED_COMPONENT_TYPES = new Set<String>{
        'dataTable',
        'form',
        'lookup',
        'recordViewer',
        'relatedList',
        'wizard',
        'modal'
    };

    public static void assertNotBlank(String value, String fieldLabel) {
        if (String.isBlank(value)) {
            throw new ValidationException(fieldLabel + ' is required.');
        }
    }

    public static void assertComponentType(String componentType) {
        assertNotBlank(componentType, 'Component type');
        if (!ALLOWED_COMPONENT_TYPES.contains(componentType)) {
            throw new ValidationException('Unknown or disallowed component type: ' + componentType);
        }
    }

    public static Boolean isAllowedComponentType(String componentType) {
        return String.isNotBlank(componentType) && ALLOWED_COMPONENT_TYPES.contains(componentType);
    }

    public static Set<String> getAllowedComponentTypes() {
        return new Set<String>(ALLOWED_COMPONENT_TYPES);
    }

    public static Integer clampPageSize(Integer pageSize, Integer defaultSize, Integer maxSize) {
        Integer resolvedDefault = defaultSize == null || defaultSize < 1 ? 20 : defaultSize;
        Integer resolvedMax = maxSize == null || maxSize < 1 ? 200 : maxSize;
        if (pageSize == null || pageSize < 1) {
            return resolvedDefault;
        }
        return Math.min(pageSize, resolvedMax);
    }
}
