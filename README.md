# Salesforce ComponentHub

**Author:** Rajesh Ediga

Open-source, metadata-driven library of reusable Lightning Web Components (LWC), secure Apex services, and configuration-based user experiences.

> Blueprint: *Salesforce ComponentHub — Ideas and Architecture* (Rajesh Ediga)

## Executive summary

ComponentHub is a set of composable packages:

- Allowlisted **component registry**
- Declarative **configuration + rules engine** (no `eval`)
- Shared **secure Apex data services**
- Reusable UI modules (DataTable, Form, Lookup, Record Viewer, …)

Recommended first build (implemented in this repository):

1. Component Registry (`chComponentRegistry` + `chComponentHost`)
2. Dynamic DataTable (`chDynamicTable`)
3. Dynamic Form Builder (`chDynamicForm`)
4. Dynamic Related List (`chDynamicRelatedList`)
5. Dynamic Lookup + Dynamic Record Viewer

## Runtime flow

```
Lightning page → chComponentHost → config validator → rules engine
→ allowlisted registry → component LWC → UI API / Apex → Salesforce records
```

## Project layout

```
salesforce-componenthub/
  force-app/main/default/
    lwc/
      chComponentHost/
      chComponentRegistry/
      chConfigValidator/
      chRulesEngine/
      chDynamicTable/
      chDynamicForm/
      chDynamicLookup/
      chDynamicRecordViewer/
      chDynamicRelatedList/
    classes/
      CH_QueryService.cls
      CH_MetadataService.cls
      CH_DmlService.cls
      CH_PaginationService.cls
      CH_LookupService.cls
      CH_ValidationService.cls
      CH_LoggingService.cls
      CH_ActionService.cls
      CH_ComponentHubTest.cls
      FileExtensionRestrictionService.cls   (existing utility module)
    customMetadata/
    objects/
  config-examples/
  docs/
  scripts/
  .github/workflows/
  README.md
  CONTRIBUTING.md
  SECURITY.md
  LICENSE
  sfdx-project.json
```

## Secure Apex services

| Service | Safeguard |
| --- | --- |
| `CH_QueryService` | Object allowlist, field FLS, bind vars / sanitized filters, user-mode |
| `CH_MetadataService` | Loads/validates published JSON config |
| `CH_DmlService` | Allowlisted writes with CRUD/FLS |
| `CH_PaginationService` | Bounded page sizes / keyset helpers |
| `CH_LookupService` | Search limits + accessible fields |
| `CH_ValidationService` | Server-side validation independent of client |
| `CH_LoggingService` | Structured errors without sensitive payloads |
| `CH_ActionService` | Named allowlisted operations only |

## Quick start

```bash
sf org login web --alias componenthub
sf project deploy start --source-dir force-app --target-org componenthub
sf apex run test --class-names CH_ComponentHubTest,FileExtensionRestrictionServiceTest --result-format human --code-coverage --target-org componenthub
```

### Use the host on a Lightning page

1. Deploy the package.
2. Edit an App or Record page.
3. Add **CH Component Host**.
4. Set **Config Developer Name** to `Sample_Account_Table`, `Sample_Account_Form`, or `Sample_Account_Contacts` (related list; place on an Account record page).

### Sample configuration shape

```json
{
  "id": "accounts",
  "type": "dataTable",
  "props": {
    "objectApiName": "Account",
    "pageSize": 20
  },
  "visibleWhen": {
    "field": "context.hasRecordId",
    "op": "eq",
    "value": false
  }
}
```

## Also included

This repository also contains the **File Extension Restriction** Apex utility (block uploads by extension + object via Custom Metadata). See earlier commits for that module’s behavior.

## Documentation

- [Architecture](docs/architecture.md)
- [Configuration schema](docs/configuration-schema.md)
- [Compatibility matrix](docs/compatibility.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)

## License

MIT © Rajesh Ediga
