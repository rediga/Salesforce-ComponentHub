/**
 * @author Rajesh Ediga
 * @description Dynamic Related List for ComponentHub — reusable related records and row actions.
 */
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import queryRecords from '@salesforce/apex/CH_QueryService.queryRecords';

const SALESFORCE_ID_PATTERN = /^[a-zA-Z0-9]{15}(?:[a-zA-Z0-9]{3})?$/;

export default class ChDynamicRelatedList extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api parentFieldApiName;
    @api fields = [];
    @api pageSize = 10;
    @api orderByField = 'Name';
    @api orderDirection = 'ASC';
    @api recordId;
    @api title = 'Related Records';

    records = [];
    columns = [];
    errorMessage;
    isLoading = false;
    lastSeenId;
    hasMore = false;

    connectedCallback() {
        this.buildColumns();
        this.loadPage(true);
    }

    buildColumns() {
        const fieldList = Array.isArray(this.fields) ? this.fields : [];
        const cols = fieldList.map((fieldName) => ({
            label: fieldName,
            fieldName,
            type: 'text'
        }));
        cols.push({
            type: 'action',
            typeAttributes: {
                rowActions: [{ label: 'View', name: 'view' }]
            }
        });
        this.columns = cols;
    }

    get whereClause() {
        if (!this.parentFieldApiName || !this.recordId) {
            return null;
        }
        if (!SALESFORCE_ID_PATTERN.test(this.recordId)) {
            return null;
        }
        return `${this.parentFieldApiName} = '${this.recordId}'`;
    }

    async loadPage(reset) {
        if (this.isLoading && !reset) {
            return;
        }
        if (!this.objectApiName) {
            this.errorMessage = 'objectApiName is required.';
            return;
        }
        if (!this.parentFieldApiName || !this.recordId) {
            this.errorMessage = 'parentFieldApiName and recordId are required for a related list.';
            return;
        }
        if (!SALESFORCE_ID_PATTERN.test(this.recordId)) {
            this.errorMessage = 'recordId must be a valid Salesforce Id.';
            return;
        }
        this.isLoading = true;
        this.errorMessage = undefined;
        try {
            const result = await queryRecords({
                request: {
                    objectApiName: this.objectApiName,
                    fields: Array.isArray(this.fields) ? this.fields : [],
                    pageSize: this.pageSize,
                    orderByField: this.orderByField,
                    orderDirection: this.orderDirection,
                    whereClause: this.whereClause,
                    lastSeenId: reset ? null : this.lastSeenId
                }
            });
            const pageRecords = (result.records || []).map((row) => ({ ...row }));
            this.records = reset ? pageRecords : [...this.records, ...pageRecords];
            this.lastSeenId = result.nextLastSeenId;
            this.hasMore = result.hasMore;
        } catch (e) {
            this.errorMessage = e?.body?.message || e?.message || 'Failed to load related records.';
        } finally {
            this.isLoading = false;
        }
    }

    handleLoadMore() {
        if (!this.hasMore || this.isLoading) {
            return;
        }
        this.loadPage(false);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'view' && row?.Id) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    actionName: 'view'
                }
            });
        }
        this.dispatchEvent(
            new CustomEvent('rowaction', {
                detail: { action: action.name, row }
            })
        );
    }

    get hasRecords() {
        return this.records && this.records.length > 0;
    }

    get cardTitle() {
        return this.title || 'Related Records';
    }
}
