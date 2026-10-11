/**
 * @author Rajesh Ediga
 * @description Dynamic DataTable for ComponentHub — columns, pagination, secure Apex queries.
 */
import { LightningElement, api } from 'lwc';
import queryRecords from '@salesforce/apex/CH_QueryService.queryRecords';

export default class ChDynamicTable extends LightningElement {
    @api objectApiName;
    @api fields = [];
    @api pageSize = 20;
    @api orderByField = 'Name';
    @api orderDirection = 'ASC';
    @api whereClause;
    @api recordId;

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
        this.columns = fieldList.map((fieldName) => ({
            label: fieldName,
            fieldName,
            type: 'text'
        }));
        if (!this.columns.find((c) => c.fieldName === 'Id')) {
            this.columns = [{ label: 'Id', fieldName: 'Id', type: 'text' }, ...this.columns];
        }
    }

    async loadPage(reset) {
        if (!this.objectApiName) {
            this.errorMessage = 'objectApiName is required.';
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
            this.errorMessage = e?.body?.message || e?.message || 'Failed to load records.';
        } finally {
            this.isLoading = false;
        }
    }

    handleLoadMore() {
        this.loadPage(false);
    }

    get hasRecords() {
        return this.records && this.records.length > 0;
    }
}
