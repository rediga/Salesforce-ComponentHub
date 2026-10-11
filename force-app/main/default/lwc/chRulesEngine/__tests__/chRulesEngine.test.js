/**
 * @author Rajesh Ediga
 */
import { evaluateRule } from 'c/chRulesEngine';

describe('chRulesEngine', () => {
    it('returns true when rule is missing', () => {
        expect(evaluateRule(null, {})).toBe(true);
    });

    it('evaluates eq predicates', () => {
        const context = { record: { Type: 'Customer' } };
        expect(
            evaluateRule({ field: 'record.Type', op: 'eq', value: 'Customer' }, context)
        ).toBe(true);
        expect(
            evaluateRule({ field: 'record.Type', op: 'eq', value: 'Partner' }, context)
        ).toBe(false);
    });

    it('evaluates and / or groups', () => {
        const context = { context: { hasRecordId: true }, record: { Type: 'Customer' } };
        expect(
            evaluateRule(
                {
                    and: [
                        { field: 'context.hasRecordId', op: 'eq', value: true },
                        { field: 'record.Type', op: 'eq', value: 'Customer' }
                    ]
                },
                context
            )
        ).toBe(true);
    });

    it('rejects unknown operators', () => {
        expect(() => evaluateRule({ field: 'a', op: 'regex', value: 'x' }, {})).toThrow();
    });
});
