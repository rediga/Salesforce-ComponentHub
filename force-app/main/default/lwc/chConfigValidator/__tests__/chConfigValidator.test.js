/**
 * @author Rajesh Ediga
 */
import { validateConfigObject } from 'c/chConfigValidator';

jest.mock('c/chComponentRegistry', () => ({
    isRegisteredType: (type) => ['dataTable', 'form', 'lookup', 'recordViewer'].includes(type)
}));

describe('chConfigValidator', () => {
    it('accepts a valid dataTable config', () => {
        const config = validateConfigObject({
            id: 'accounts',
            type: 'dataTable',
            props: { objectApiName: 'Account', pageSize: 20 }
        });
        expect(config.id).toBe('accounts');
    });

    it('rejects unknown types', () => {
        expect(() =>
            validateConfigObject({ id: 'x', type: 'evilWidget', props: {} })
        ).toThrow(/Unknown or disallowed/);
    });

    it('requires id and type', () => {
        expect(() => validateConfigObject({ type: 'dataTable' })).toThrow(/id/);
        expect(() => validateConfigObject({ id: 'x' })).toThrow(/type/);
    });
});
