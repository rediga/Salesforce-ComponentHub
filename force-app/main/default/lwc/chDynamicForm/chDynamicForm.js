/**
 * @author Rajesh Ediga
 * @description Schema-driven create/edit form for ComponentHub.
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import performDml from '@salesforce/apex/CH_DmlService.performDml';

export default class ChDynamicForm extends LightningElement {
    @api objectApiName = 'Account';
    @api fields = ['Name', 'Type', 'Phone'];
    @api mode = 'create';
    @api recordId;

    draft = {};
    errorMessage;
    isSaving = false;

    get fieldList() {
        return Array.isArray(this.fields) ? this.fields : [];
    }

    get isEdit() {
        return (this.mode || '').toLowerCase() === 'edit';
    }

    get cardTitle() {
        return this.isEdit ? 'ComponentHub Edit Form' : 'ComponentHub Create Form';
    }

    handleChange(event) {
        const fieldName = event.target.dataset.field;
        this.draft = { ...this.draft, [fieldName]: event.target.value };
    }

    async handleSave() {
        this.isSaving = true;
        this.errorMessage = undefined;
        try {
            const operation = this.isEdit ? 'update' : 'insert';
            const fieldValues = { ...this.draft };
            if (!this.isEdit && !fieldValues.Name && this.objectApiName === 'Account') {
                throw new Error('Name is required.');
            }
            const id = await performDml({
                request: {
                    objectApiName: this.objectApiName,
                    operation,
                    fieldValues,
                    recordId: this.recordId
                }
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Saved',
                    message: `Record ${id} saved successfully.`,
                    variant: 'success'
                })
            );
            this.dispatchEvent(new CustomEvent('save', { detail: { id } }));
        } catch (e) {
            this.errorMessage = e?.body?.message || e?.message || 'Save failed.';
        } finally {
            this.isSaving = false;
        }
    }
}
