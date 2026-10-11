/**
 * @author Rajesh Ediga
 * @description Object-aware record field display for ComponentHub.
 */
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class ChDynamicRecordViewer extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fields = ['Name'];

    errorMessage;
    fieldViews = [];

    get uiFields() {
        if (!this.objectApiName || !this.recordId) {
            return [];
        }
        const list = Array.isArray(this.fields) ? this.fields : [];
        return list.map((f) => `${this.objectApiName}.${f}`);
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$uiFields' })
    wiredRecord({ data, error }) {
        if (error) {
            this.errorMessage = error?.body?.message || 'Unable to load record.';
            this.fieldViews = [];
            return;
        }
        if (data) {
            this.errorMessage = undefined;
            const list = Array.isArray(this.fields) ? this.fields : [];
            this.fieldViews = list.map((fieldName) => {
                const value = data.fields?.[fieldName]?.displayValue ?? data.fields?.[fieldName]?.value;
                return { fieldName, value: value == null ? '' : String(value) };
            });
        }
    }

    get hasFields() {
        return this.fieldViews && this.fieldViews.length > 0;
    }
}
