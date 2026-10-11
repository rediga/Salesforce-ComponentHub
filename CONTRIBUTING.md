# Contributing to Salesforce ComponentHub

**Author:** Rajesh Ediga

Thank you for contributing. ComponentHub is a modular, metadata-driven library of reusable Lightning Web Components and secure Apex services.

## Development setup

1. Clone this repository.
2. Authenticate to a scratch or sandbox org: `sf org login web --alias componenthub`.
3. Deploy: `sf project deploy start --source-dir force-app --target-org componenthub`.
4. (Optional) Install Jest deps: `npm install` then `npm test`.

## Contribution guidelines

- Prefer declarative configuration over hard-coded UI behavior.
- New UI modules must register in `chComponentRegistry` with an explicit prop allowlist.
- Apex services must include positive and negative security tests (allowlist, FLS, CRUD).
- Do not introduce dynamic Apex type resolution or client-side `eval`.
- Keep author attribution as **Rajesh Ediga** on new module headers unless transferring ownership intentionally.
- Open a PR with a clear summary, test plan, and any schema version impacts.

## Suggested first areas

1. Dynamic DataTable enhancements (bulk actions, column types).
2. Dynamic Form Builder validation rules.
3. Additional allowlisted component modules from the project backlog.
