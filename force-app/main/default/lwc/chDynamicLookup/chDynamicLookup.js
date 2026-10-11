/**
 * @author Rajesh Ediga
 * @description Dynamic lookup search/selection for ComponentHub.
 */
import { LightningElement, api } from 'lwc';
import search from '@salesforce/apex/CH_LookupService.search';

export default class ChDynamicLookup extends LightningElement {
    @api objectApiName = 'Account';
    @api nameField = 'Name';
    @api limitSize = 10;
    @api label = 'Lookup';
    @api value;

    options = [];
    searchTerm = '';
    errorMessage;
    selectedLabel;

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    async handleSearch() {
        this.errorMessage = undefined;
        try {
            this.options = await search({
                request: {
                    objectApiName: this.objectApiName,
                    searchTerm: this.searchTerm,
                    nameField: this.nameField,
                    limitSize: this.limitSize
                }
            });
        } catch (e) {
            this.errorMessage = e?.body?.message || e?.message || 'Lookup search failed.';
            this.options = [];
        }
    }

    handleSelect(event) {
        event.preventDefault();
        const id = event.currentTarget.dataset.id;
        const label = event.currentTarget.dataset.label;
        this.value = id;
        this.selectedLabel = label;
        this.dispatchEvent(
            new CustomEvent('select', {
                detail: { id, label }
            })
        );
    }

    get hasOptions() {
        return this.options && this.options.length > 0;
    }
}
