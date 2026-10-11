/**
 * @author Rajesh Ediga
 * @description Allowlisted ComponentHub registry. Unknown keys are rejected.
 */
import CH_DYNAMIC_TABLE from 'c/chDynamicTable';
import CH_DYNAMIC_FORM from 'c/chDynamicForm';
import CH_DYNAMIC_LOOKUP from 'c/chDynamicLookup';
import CH_DYNAMIC_RECORD_VIEWER from 'c/chDynamicRecordViewer';

const REGISTRY = Object.freeze({
    dataTable: {
        ctor: CH_DYNAMIC_TABLE,
        allowedProps: Object.freeze([
            'objectApiName',
            'fields',
            'pageSize',
            'orderByField',
            'orderDirection',
            'whereClause',
            'recordId'
        ])
    },
    form: {
        ctor: CH_DYNAMIC_FORM,
        allowedProps: Object.freeze([
            'objectApiName',
            'fields',
            'mode',
            'recordId'
        ])
    },
    lookup: {
        ctor: CH_DYNAMIC_LOOKUP,
        allowedProps: Object.freeze([
            'objectApiName',
            'nameField',
            'limitSize',
            'label',
            'value'
        ])
    },
    recordViewer: {
        ctor: CH_DYNAMIC_RECORD_VIEWER,
        allowedProps: Object.freeze([
            'objectApiName',
            'fields',
            'recordId'
        ])
    }
});

export function isRegisteredType(typeKey) {
    return Boolean(typeKey && REGISTRY[typeKey]);
}

export function getRegisteredTypes() {
    return Object.keys(REGISTRY);
}

export function resolveComponent(typeKey) {
    if (!isRegisteredType(typeKey)) {
        throw new Error(`ComponentHub rejected unknown component type: ${typeKey}`);
    }
    return REGISTRY[typeKey];
}

export function filterAllowedProps(typeKey, props = {}) {
    const entry = resolveComponent(typeKey);
    const safe = {};
    entry.allowedProps.forEach((propName) => {
        if (Object.prototype.hasOwnProperty.call(props, propName)) {
            safe[propName] = props[propName];
        }
    });
    return safe;
}
