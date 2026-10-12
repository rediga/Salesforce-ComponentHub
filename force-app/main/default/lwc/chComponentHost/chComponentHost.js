/**
 * @author Rajesh Ediga
 * @description Host LWC: loads config, validates schema, evaluates rules, renders allowlisted modules.
 */
import { LightningElement, api, wire } from 'lwc';
import getComponentConfig from '@salesforce/apex/CH_MetadataService.getComponentConfig';
import { parseAndValidateConfig } from 'c/chConfigValidator';
import { filterAllowedProps, isRegisteredType } from 'c/chComponentRegistry';
import { evaluateRule } from 'c/chRulesEngine';

export default class ChComponentHost extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api configDeveloperName;

    config;
    safeProps = {};
    errorMessage;
    isVisible = false;
    isLoading = true;

    @wire(getComponentConfig, { developerName: '$configDeveloperName' })
    wiredConfig({ data, error }) {
        this.isLoading = false;
        this.errorMessage = undefined;
        if (error) {
            this.errorMessage = this.normalizeError(error);
            this.isVisible = false;
            return;
        }
        if (data) {
            this.applyConfig(data);
        }
    }

    applyConfig(data) {
        try {
            const parsed = parseAndValidateConfig(data.configJson);
            if (!isRegisteredType(parsed.type)) {
                throw new Error(`Unknown component type: ${parsed.type}`);
            }
            this.config = parsed;
            this.safeProps = filterAllowedProps(parsed.type, {
                ...(parsed.props || {}),
                recordId: this.recordId,
                objectApiName: parsed.props?.objectApiName || this.objectApiName
            });
            const context = {
                record: { Id: this.recordId },
                context: {
                    hasRecordId: Boolean(this.recordId),
                    objectApiName: this.objectApiName
                }
            };
            this.isVisible = evaluateRule(parsed.visibleWhen, context);
        } catch (e) {
            this.errorMessage = e.message || 'Failed to load ComponentHub configuration.';
            this.isVisible = false;
            this.config = undefined;
        }
    }

    get showDataTable() {
        return this.isVisible && this.config?.type === 'dataTable';
    }
    get showForm() {
        return this.isVisible && this.config?.type === 'form';
    }
    get showLookup() {
        return this.isVisible && this.config?.type === 'lookup';
    }
    get showRecordViewer() {
        return this.isVisible && this.config?.type === 'recordViewer';
    }
    get showRelatedList() {
        return this.isVisible && this.config?.type === 'relatedList';
    }

    get tableProps() {
        return this.safeProps;
    }

    normalizeError(error) {
        return error?.body?.message || error?.message || 'Unable to load ComponentHub configuration.';
    }
}
