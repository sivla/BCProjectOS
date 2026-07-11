# BCProjectOS and Project Twin Boundary

Status: High-level contract

## Product Roles

### BCProjectOS

Owns canonical customer-workspace state:

- company and Business Central knowledge;
- projects, support cases, meetings, files, budgets, and relations;
- OpenSpec changes and delivery gates;
- evidence and immutable-source references;
- local generation and validation;
- controlled lifecycle transitions.

### Project Twin

Owns visualization and interaction presentation:

- dashboards, boards, timelines, filters, and navigation;
- project, support, budget, meeting, file, and change views;
- warnings and readiness visualization;
- presentation preferences that do not alter canonical business state.

Project Twin is not a second source of truth.

## Initial Integration Rule

BCProjectOS eventually generates one read-only projection such as:

```text
exports/project-twin/workspace-snapshot.json
```

The snapshot may contain:

- workspace and blueprint version;
- entity IDs, types, titles, statuses, and relations;
- project and support board summaries;
- budget plan/actual/forecast summaries;
- meeting and external-file processing status;
- OpenSpec and delivery-gate status;
- local relative links to canonical or generated artifacts;
- freshness, source revision, and generated-at metadata.

It must not contain:

- original binary files;
- access tokens, tenant IDs, connection strings, or credentials;
- unnecessary personal data;
- fabricated approvals or inferred completion;
- write commands for BCProjectOS.

## Ownership Contract

| Concern | Owner |
|---|---|
| Canonical business state | BCProjectOS |
| Files, evidence, and hashes | BCProjectOS |
| Workflow and gate rules | BCProjectOS |
| Snapshot schema and generation | BCProjectOS |
| Dashboard and board rendering | Project Twin |
| Visual preferences | Project Twin |
| External system synchronization | Deferred platform capability |

## Platform Evolution

### Level 1 - Local Workspace

Folders, Markdown, JSON, PowerShell, OpenSpec, and local validation. No Twin dependency.

### Level 2 - Stable Read Model

Versioned JSON schemas and deterministic read-only snapshots. Project Twin may consume fixture snapshots without accessing BCProjectOS internals.

### Level 3 - Twin Visualization

Project Twin renders projects, support, meetings, budgets, files, changes, and gates from the snapshot. BCProjectOS remains authoritative and Twin remains read-only.

### Level 4 - Local Service

Only after proven need: a local API or service replaces file polling. Commands require explicit contracts, validation, audit, and authorization.

### Level 5 - Platform

Only after repeated multi-customer use: database, authentication, tenant isolation, background processing, connectors, audit trail, deployment, monitoring, and controlled write APIs.

No Level 4 or Level 5 implementation belongs to the current MVP roadmap.

## Coupling Rules

- BCProjectOS must remain usable without Project Twin.
- Project Twin must consume a versioned public snapshot, not crawl internal folders.
- Snapshot changes require schema versioning and compatibility checks.
- Missing or stale data must be displayed as unknown or stale, never guessed.
- Initial Twin integration is read-only.
- No changes to the Project Twin repository are authorized by this architecture note.
