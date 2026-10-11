# ComponentHub reference architecture

**Author:** Rajesh Ediga

| Layer | Responsibility |
| --- | --- |
| Experience / host LWC | Placed on Lightning pages; reads `recordId`, `objectApiName`, config developer name |
| Configuration service | Loads versioned JSON from Custom Metadata; validates schemas and defaults |
| Registry + renderer | Maps approved component keys to statically imported LWCs; rejects unknown types |
| Rules engine | Evaluates declarative visibility predicates; no `eval` |
| Data and action services | UI API / LDS first; Apex for authorized queries and writes |
| Component modules | DataTable, Form, Lookup, Record Viewer, … |
| Observability / CI | Unit tests, static analysis, configuration validation |

## Packaging constraints

- MVP uses statically imported, allowlisted LWC templates (conditional render in `chComponentHost`).
- Configuration is declarative only — no administrator-supplied SOQL fragments, JavaScript, or arbitrary Apex class names.
- Semantic versioning starts at `0.1.0`.
