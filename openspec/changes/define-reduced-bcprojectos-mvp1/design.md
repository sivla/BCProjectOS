## Context

The accepted MVP-0 contract defines a file-based, local-first customer workspace with one customer root, canonical IDs, controlled catalogs, one OpenSpec root, and strict separation between originals, curated knowledge, Evidence, work records, and generated output. The user accepted the Proof-of-Value recommendation `Reduce`, authorizing only the lean MVP-1 blank workspace and rudimentary BC baseline.

The repository is the BCProjectOS development workspace. A generated workspace will eventually be a separate customer instance and must not be populated with Universaarl-specific or other customer-specific knowledge. This change specifies that future behavior but performs no installation.

## Goals / Non-Goals

**Goals:**

- Specify one deterministic local PowerShell entry point for blank-workspace creation.
- Make every generated path and structured value verifiable against accepted MVP-0 sources.
- Support `implementation`, `support-only`, and `mixed` without creating unused records.
- Keep all four initial BC areas navigable but fact-free.
- Fail closed before exposing a partial or misleading workspace.
- Derive release identity and blueprint version only from verified immutable release Evidence.
- Permit only clearly marked, non-installable synthetic fixtures before a real installable release exists.

**Non-Goals:**

- Implementing the command, validator, templates, release manifest, migration, or product functionality in this change.
- Modeling customer operations, delivery, file intake, meetings, tickets, Evidence, budgets, or external integrations.
- Reusing the technical spike as the blank-workspace template.

## Decisions

### Decision: One Future PowerShell Entry Point

The later implementation SHALL expose one documented command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File automation/New-CustomerWorkspace.ps1 `
  -Destination <local-path> `
  -Profile <implementation|support-only|mixed> `
  -CustomerAlias <non-sensitive-alias> `
  [-ExpectedBlueprintVersion <semver>]
```

The exact script does not exist in this change. Release identity SHALL be discovered from verified BCProjectOS release Evidence, not asserted by the operator. `-ExpectedBlueprintVersion`, if supplied, is only a comparison value and MUST match the verified release version exactly. It is never sufficient release Evidence. A later test-only mode MAY use an explicit `-SyntheticFixture` switch, but it MUST NOT publish an installable customer workspace.

### Decision: Stage, Validate, Then Publish Locally

The future generator SHALL build in a new sibling staging directory, validate the complete result, and only then rename it to the requested destination. Existing non-empty destinations, invalid input, schema failure, catalog mismatch, a second OpenSpec root, or any failed invariant MUST leave the requested destination and existing files unchanged. The implementation SHALL clean only its own newly created staging directory.

### Decision: MVP-0 Structure Is Normative

The generated root SHALL contain the high-level paths from `contract/workspace-architecture.md`. No alternative product architecture is introduced. Empty runtime directories may remain physically empty; the generator MUST NOT insert fake entities merely to preserve them in Git.

### Decision: Workspace Identity and Profile Are Separate

`workspace.yaml` SHALL validate against `schemas/workspace.schema.json` without additional fields. The selected profile SHALL be stored separately under `governance/policies/workspace-profile.yaml` and constrained to `implementation`, `support-only`, or `mixed`. A profile controls navigation and later permitted workflows; it does not create projects, support cases, meetings, tickets, Evidence, or approvals.

### Decision: Catalogs Are Managed Copies

The future generator SHALL copy the controlled files from `catalogs/` into `governance/catalogs/` without adding or silently changing values. Validation SHALL compare names and SHA-256 content hashes against the selected product input. A mismatch or unknown catalog is a hard failure.

### Decision: Four Fact-Free BC Areas

The generated workspace SHALL provide navigable empty roots for:

```text
knowledge/bc/sales/
knowledge/bc/purchasing/
knowledge/bc/inventory/
knowledge/bc/finance/
```

Each area may contain only a managed navigation marker stating that no customer knowledge has been recorded. It MUST NOT contain process assumptions, setup values, object IDs, roles, extensions, integrations, requirements, or example transactions.

### Decision: Verified Release Evidence Gates Installable Workspaces

The future command SHALL create or locally publish an installable customer workspace only after verifying all of the following as one consistent release identity:

- a correctly named annotated release tag `bcprojectos-v<SemVer>` exists;
- the tag resolves to a concrete release commit;
- the tagged commit contains the matching final product/release manifest;
- the manifest declares an installable blueprint and the same version as the tag;
- the manifest-recorded release commit, when the installable manifest contract provides it, equals the resolved tag commit;
- the manifest source commit is valid, is in the tagged release history, and the released payload did not change after that source commit;
- the SHA-256 digest recomputed from the released product scope at the verified commit equals the manifest digest;
- any optional `-ExpectedBlueprintVersion` equals the verified manifest/tag version.

Only the verified manifest version SHALL be written to `blueprint_version` and `created_with_version`; `blueprint_id` remains `bcprojectos`. The command MUST NOT accept a free SemVer assertion as the version source or infer a release from Git directory names, Git HEAD, roadmap text, `0.1.0`, working-tree state, release-candidate directories, candidate manifests, checksum presence, or expected tag names.

The existing `0.0.1` candidate is explicitly non-installable (`CONTRACT_REFERENCE_ONLY`, `installable_blueprint: false`) and lacks a final immutable binding. Its files and scripts are useful candidate Evidence but are not proof of a published installable release. Missing, unknown, incomplete, or contradictory release state MUST abort with non-zero exit and retain `PENDING_BCPROJECTOS_RELEASE`.

### Decision: Synthetic Fixtures Are Not Customer Workspaces

Before a verified installable release exists, implementation tests MAY create only explicitly marked synthetic fixtures in test-owned temporary locations. Such fixtures MUST declare `synthetic: true`, `installable: false`, and release status `PENDING_BCPROJECTOS_RELEASE` in test metadata outside canonical `workspace.yaml`. They MUST contain no customer, tenant, company, environment, Evidence, approval, or operational data and MUST NOT be published, installed, or reported as complete customer workspaces.

`workspace.schema.json` currently requires SemVer values for `blueprint_version` and `created_with_version`. This change does not invent a placeholder SemVer and does not modify the schema or product contract. Until a separate contract decision defines a lawful pre-release fixture representation, a pre-release synthetic fixture that lacks verified version Evidence MAY be intentionally schema-incomplete for negative testing, but MUST NOT pass customer-workspace validation. A positive schema-valid installable workspace test requires verified installable release Evidence.

### Decision: Exactly One OpenSpec Root

The generated workspace SHALL contain only `<workspace>/openspec/` as its OpenSpec root. Profile-specific or project-specific OpenSpec roots are forbidden. The root begins empty of changes and accepted customer specs except for generic managed configuration required by the blueprint.

## Validation Model

The later validator SHALL be read-only and SHALL check at least:

- destination containment and absence of path traversal or reparse-point escape;
- exact required high-level paths;
- `workspace.yaml` syntax and schema conformance;
- customer ID self-namespace and stable `CUS-*` format;
- profile enum and honest empty-profile invariants;
- catalog file set and SHA-256 equality;
- exactly one OpenSpec root;
- exactly four initial BC-area roots and absence of customer facts;
- absence of canonical project, support, meeting, ticket, Requirement, Change, Evidence, original-file, and generated-delivery records;
- absence of credential-, tenant-, environment-, and customer-data-shaped values;
- complete and consistent tag, commit, final manifest, installable-release claim, product-scope digest, and optional expected-version match;
- explicit rejection of release candidates and synthetic fixtures as installable customer workspaces.

The generator and validator SHALL return non-zero on any unknown, missing, contradictory, or extra controlled value.

## Risks / Trade-offs

- **Empty directories are not durable in Git:** Generated local workspaces can preserve them on disk; MVP 1 must not add fake records or excessive placeholder files solely for source-control visibility.
- **Profile differences are intentionally small:** This reduces ceremony but means later MVPs must add behavior without redefining profile identity.
- **Release Evidence contract needs an installable manifest shape:** The current contract-only candidate has no installable blueprint and no verified release commit. MVP-1 implementation must resolve the installable manifest fields without modifying this OpenSpec-only correction.
- **Synthetic fixture schema conflict:** The current workspace schema requires SemVer fields, so pre-release fixtures cannot be both schema-valid and free of invented version claims until a separate contract decision resolves that representation.
- **Copied catalogs can become stale:** Hash validation makes drift visible; automatic upgrade and migration remain outside this MVP.
- **Path safety is platform-sensitive:** The Windows implementation must validate resolved paths and reparse points before any publish/rename step.

## Rollback

Before final publish, failure removes only the generator-owned staging directory. After a successful local creation, rollback is explicit deletion of that newly generated synthetic/blank destination by the operator; the generator itself does not delete existing customer workspaces. Upgrade and restore behavior remain governed by the MVP-0 versioning and backup contracts.

## Release Status

`PENDING_BCPROJECTOS_RELEASE` remains mandatory until a real immutable release tag, resolved commit, final installable manifest, and matching released product-scope digest are verified together.
