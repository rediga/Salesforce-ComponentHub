/**
 * @author Rajesh Ediga
 * @description Declarative visibility/enablement rules. No eval.
 */

function resolvePath(context, path) {
    if (!path || typeof path !== 'string') {
        return undefined;
    }
    return path.split('.').reduce((acc, key) => {
        if (acc === null || acc === undefined) {
            return undefined;
        }
        return acc[key];
    }, context);
}

function compare(left, op, right) {
    switch (op) {
        case 'eq':
            return left === right;
        case 'ne':
            return left !== right;
        case 'gt':
            return left > right;
        case 'gte':
            return left >= right;
        case 'lt':
            return left < right;
        case 'lte':
            return left <= right;
        case 'in':
            return Array.isArray(right) && right.includes(left);
        case 'exists':
            return left !== null && left !== undefined && left !== '';
        default:
            throw new Error(`Unsupported ComponentHub rule operator: ${op}`);
    }
}

/**
 * @param {object|null} rule visibleWhen / enabledWhen predicate
 * @param {object} context host context (record, user, context flags)
 * @returns {boolean}
 */
export function evaluateRule(rule, context = {}) {
    if (!rule) {
        return true;
    }
    if (rule.and && Array.isArray(rule.and)) {
        return rule.and.every((child) => evaluateRule(child, context));
    }
    if (rule.or && Array.isArray(rule.or)) {
        return rule.or.some((child) => evaluateRule(child, context));
    }
    if (!rule.field || !rule.op) {
        throw new Error('ComponentHub rule requires field and op.');
    }
    const left = resolvePath(context, rule.field);
    return compare(left, rule.op, rule.value);
}
