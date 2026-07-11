## Why

Spectra MVP 0 has frozen the customer-workspace contract, and the synthetic Proof of Value was accepted with the decision `Reduce`. The technical repository remains BCProjectOS. MVP 1 now needs a durable, reviewable specification for the smallest reusable blank customer workspace before any generator or product function is implemented.

The specification must prevent a blank workspace from becoming a source of fabricated customer facts, project state, support history, approvals, Evidence, or release claims. It must also preserve the Universaarl architecture boundary: Spectra defines a customer-independent blueprint contract but is not a customer instance, control center, Project Twin, or external system.

## What Changes

- Define the reduced `Blank Customer Workspace and BC Baseline` capability.
- Specify one future local PowerShell command that creates and validates an installable blank workspace only from verified immutable release Evidence.
- Require the accepted MVP-0 high-level structure, `workspace.yaml` schema, controlled catalogs, supported profiles, and exactly one OpenSpec root.
- Define a rudimentary, navigable, fact-free baseline for Sales, Purchasing, Inventory, and Finance.
- Define deterministic, fail-closed acceptance and negative scenarios and implement only the non-installable synthetic-fixture and consumer-binding safeguards that those scenarios require.
- Separate installable customer workspaces from explicitly marked, non-installable synthetic development fixtures.
- Define a portable machine-readable consumer binding that distinguishes an evidence-free pending state from a repository-verified bound state.
- Keep blueprint release status explicitly `PENDING_BCPROJECTOS_RELEASE` until a real immutable tag, resolved commit, final installable product manifest, and matching product-scope digest are verified together.

## Capabilities

### New Capabilities

- `bcprojectos-blank-customer-workspace`: Defines deterministic creation and validation of the reduced MVP-1 blank customer workspace and BC baseline.

### Modified Capabilities

- None.

## Impact

- Adds the specification artifacts, non-installable synthetic-fixture gates, and consumer-binding schema/validator under this OpenSpec change.
- Keeps installable customer-workspace generation, release binding, snapshots, external connections and Business Central writes blocked.
- Does not change `examples/bc-enterprise-blueprint/`.
- Does not treat a repository URL, a SemVer string, a candidate artifact, checksums or an expected tag name as published or installable release evidence.

## Non-Goals

- MVP 2 or later functionality, including inbox processing, OCR, classification, meeting processing, project/support control, OpenSpec promotion automation, or full delivery generation.
- UI, API, database, service, authentication, multi-tenancy, Project Twin, snapshot generation, control-center installation, or external publishing.
- Jira, Confluence, SharePoint, email, Teams, time-tracking, accounting, or Business Central integration.
- Real customer, tenant, company, environment, project, support, meeting, Evidence, approval, UAT, training, release, budget, or commercial data.
- Multiple OpenSpec roots or copying the technical delivery spike into a generated workspace.

## Release Status

`PENDING_BCPROJECTOS_RELEASE`. A syntactically valid SemVer, roadmap text, working-tree content, candidate artifact, checksum file, expected tag name or repository URL is not release Evidence. This change neither creates nor implies an installable Spectra release.
