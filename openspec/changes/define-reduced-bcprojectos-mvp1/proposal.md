## Why

BCProjectOS MVP 0 has frozen the customer-workspace contract, and the synthetic Proof of Value was accepted with the decision `Reduce`. MVP 1 now needs a durable, reviewable specification for the smallest reusable blank customer workspace before any generator or product function is implemented.

The specification must prevent a blank workspace from becoming a source of fabricated customer facts, project state, support history, approvals, Evidence, or release claims. It must also preserve the Universaarl architecture boundary: BCProjectOS defines a customer-independent blueprint contract but is not a customer instance, control center, Project Twin, or external system.

## What Changes

- Define the reduced `Blank Customer Workspace and BC Baseline` capability.
- Specify one future local PowerShell command that creates and validates an installable blank workspace only from verified immutable release Evidence.
- Require the accepted MVP-0 high-level structure, `workspace.yaml` schema, controlled catalogs, supported profiles, and exactly one OpenSpec root.
- Define a rudimentary, navigable, fact-free baseline for Sales, Purchasing, Inventory, and Finance.
- Define deterministic, fail-closed acceptance and negative scenarios without implementing the generator.
- Separate installable customer workspaces from explicitly marked, non-installable synthetic development fixtures.
- Keep blueprint release status explicitly `PENDING_BCPROJECTOS_RELEASE` until a real immutable tag, resolved commit, final installable product manifest, and matching product-scope digest are verified together.

## Capabilities

### New Capabilities

- `bcprojectos-blank-customer-workspace`: Defines deterministic creation and validation of the reduced MVP-1 blank customer workspace and BC baseline.

### Modified Capabilities

- None.

## Impact

- Adds specification artifacts only under this new OpenSpec change.
- Provides the implementation contract for `automation/New-CustomerWorkspace.ps1` and its validator.
- Does not create a generator, customer workspace, product release, release tag, version binding, snapshot, external connection, or Business Central write.
- Does not change `examples/bc-enterprise-blueprint/` or the existing `evaluate-openspec-for-bc-workflows` change.
- Does not reinterpret the existing `0.0.1` release-candidate files, manifest, checksums, or validation scripts as proof of a published or installable release.

## Non-Goals

- MVP 2 or later functionality, including inbox processing, OCR, classification, meeting processing, project/support control, OpenSpec promotion automation, or full delivery generation.
- UI, API, database, service, authentication, multi-tenancy, Project Twin, snapshot generation, control-center installation, or external publishing.
- Jira, Confluence, SharePoint, email, Teams, time-tracking, accounting, or Business Central integration.
- Real customer, tenant, company, environment, project, support, meeting, Evidence, approval, UAT, training, release, budget, or commercial data.
- Multiple OpenSpec roots or copying the technical delivery spike into a generated workspace.

## Release Status

`PENDING_BCPROJECTOS_RELEASE`. A syntactically valid SemVer, roadmap text, working-tree content, release-candidate directory, candidate manifest, checksum file, or expected tag name is not release Evidence. This change neither creates nor implies an installable BCProjectOS release.
