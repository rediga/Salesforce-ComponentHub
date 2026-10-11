/**
 * @author Rajesh Ediga
 * @description Client-side configuration schema validation for ComponentHub.
 */
import { isRegisteredType } from 'c/chComponentRegistry';

export function parseAndValidateConfig(configJson) {
    if (!configJson || typeof configJson !== 'string') {
        throw new Error('ComponentHub config JSON is required.');
    }
    let parsed;
    try {
        parsed = JSON.parse(configJson);
    } catch (e) {
        throw new Error('ComponentHub config JSON is invalid.');
    }
    return validateConfigObject(parsed);
}

export function validateConfigObject(config) {
    if (!config || typeof config !== 'object' || Array.isArray(config)) {
        throw new Error('ComponentHub config must be an object.');
    }
    if (!config.id || typeof config.id !== 'string') {
        throw new Error('ComponentHub config requires string id.');
    }
    if (!config.type || typeof config.type !== 'string') {
        throw new Error('ComponentHub config requires string type.');
    }
    if (!isRegisteredType(config.type)) {
        throw new Error(`Unknown or disallowed component type: ${config.type}`);
    }
    if (config.props != null && (typeof config.props !== 'object' || Array.isArray(config.props))) {
        throw new Error('ComponentHub config props must be an object when provided.');
    }
    return config;
}
