# Security Policy

**Author:** Rajesh Ediga

## Supported versions

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |

## Reporting a vulnerability

Please open a private security advisory on GitHub or email the maintainer. Do not post exploit details in public issues.

## Security principles for ComponentHub

- Configuration is declarative JSON / Custom Metadata only. No `eval`, no administrator-supplied SOQL fragments, and no arbitrary Apex class invocation.
- Component types must resolve through the allowlisted registry (`chComponentRegistry`).
- Apex data access enforces object allowlists, field allowlists, CRUD/FLS, bind variables, and user-mode queries where appropriate.
- Logging must never persist sensitive record payloads.
