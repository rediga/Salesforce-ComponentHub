# Configuration schema (v0.1)

**Author:** Rajesh Ediga

A component definition includes `id`, `type`, `props`, optional `visibleWhen`, and optional `dataSource`.

## Required fields

| Field | Type | Notes |
| --- | --- | --- |
| `id` | string | Stable configuration identifier |
| `type` | string | Must be registered (`dataTable`, `form`, `lookup`, `recordViewer`, …) |
| `props` | object | Filtered by per-type allowlist in `chComponentRegistry` |

## `visibleWhen` predicate

```json
{ "field": "context.hasRecordId", "op": "eq", "value": true }
```

Supported operators: `eq`, `ne`, `gt`, `gte`, `lt`, `lte`, `in`, `exists`, plus nested `and` / `or` arrays.

## Versioning

Store schema/document version in `CH_Component_Definition__mdt.Version__c` (semver). Breaking prop contract changes require a major version bump and regression tests.
