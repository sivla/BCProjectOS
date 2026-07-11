## ADDED Requirements

### Requirement: One local command creates a complete blank workspace
The future MVP-1 implementation SHALL expose exactly one documented local PowerShell command that creates one complete blank BCProjectOS customer workspace for a requested destination and profile.

#### Scenario: Valid creation request
- **WHEN** the operator supplies a new local destination, a supported profile, and a non-sensitive customer alias, and the product has complete verified installable release Evidence
- **THEN** the command SHALL create, validate, and locally publish exactly one complete workspace
- **AND** it SHALL return exit code zero only after all MVP-1 invariants pass

#### Scenario: Destination already contains data
- **WHEN** the requested destination exists and is not empty
- **THEN** the command MUST fail with a non-zero exit code
- **AND** it MUST leave every existing destination file unchanged

#### Scenario: Creation fails after staging starts
- **WHEN** any generation or validation step fails before local publish
- **THEN** the command MUST NOT expose a partial workspace at the requested destination
- **AND** it MAY remove only the staging directory created by that invocation

### Requirement: Generated structure conforms to the accepted workspace architecture
The generated workspace SHALL contain the high-level structure defined by `contract/workspace-architecture.md` without introducing a competing root layout.

#### Scenario: Generated tree is validated
- **WHEN** the future validator enumerates the generated workspace
- **THEN** every required high-level path from the accepted architecture SHALL exist
- **AND** no path SHALL escape the customer-workspace root

#### Scenario: Required path is missing or redirected
- **WHEN** a required path is absent, outside the resolved root, or traverses a reparse point outside the root
- **THEN** validation MUST fail closed
- **AND** the workspace MUST NOT be reported as ready

### Requirement: Workspace metadata conforms to the canonical schema
The generated `workspace.yaml` SHALL parse successfully and SHALL conform to `schemas/workspace.schema.json` without additional properties.

#### Scenario: Canonical workspace metadata is generated
- **WHEN** a valid blank workspace is created
- **THEN** `workspace.yaml` SHALL contain a stable self-namespaced `CUS-*` ID, entity type `customer`, lifecycle status, creation timestamp, empty relations, blueprint identity, version fields, and one OpenSpec root

#### Scenario: Metadata is missing, unknown, or contradictory
- **WHEN** a required property is absent, an additional property is present, customer IDs differ, or a controlled value is invalid
- **THEN** validation MUST return non-zero
- **AND** the workspace MUST NOT be published as complete

### Requirement: Controlled catalogs are copied without drift
The future generator SHALL take the complete controlled catalog set from `catalogs/` and place managed copies under `governance/catalogs/`.

#### Scenario: Catalog copies match the product input
- **WHEN** the workspace is validated after generation
- **THEN** catalog names and SHA-256 hashes SHALL match the selected BCProjectOS product input exactly

#### Scenario: Catalog is missing, modified, or unknown
- **WHEN** a catalog file is absent, its content hash differs, or an extra uncontrolled catalog is present
- **THEN** validation MUST fail closed
- **AND** no catalog value SHALL be inferred or silently accepted

### Requirement: Three lean workspace profiles are supported
The future generator SHALL support only `implementation`, `support-only`, and `mixed`, recorded separately from canonical `workspace.yaml` metadata.

#### Scenario: Supported profile is selected
- **WHEN** the operator selects one of the three controlled profile values
- **THEN** `governance/policies/workspace-profile.yaml` SHALL record exactly that value
- **AND** the profile SHALL NOT create operational records by itself

#### Scenario: Unsupported or missing profile is supplied
- **WHEN** the profile is absent or is not one of the three controlled values
- **THEN** the command MUST fail before local publish
- **AND** it MUST NOT choose a default by guessing

### Requirement: Unused profiles and operational areas remain honestly empty
A blank workspace MUST NOT fabricate customer facts or operational entities for any profile.

#### Scenario: Implementation profile is created
- **WHEN** profile `implementation` is selected
- **THEN** project, support, meeting, ticket, Requirement, Change, Evidence, original-file, and generated-delivery collections SHALL contain no canonical records

#### Scenario: Support-only profile is created
- **WHEN** profile `support-only` is selected
- **THEN** support navigation MAY exist but support cases, projects, meetings, tickets, Evidence, and Changes SHALL remain empty

#### Scenario: Mixed profile is created
- **WHEN** profile `mixed` is selected
- **THEN** project and support navigation MAY exist but both SHALL remain free of fabricated operational records

#### Scenario: Placeholder resembles an approved or completed record
- **WHEN** a generated file claims a project, support case, meeting, ticket, Requirement, Change, Evidence, approval, UAT, training, release, customer fact, or completed work
- **THEN** validation MUST fail closed

### Requirement: Four BC areas provide only a rudimentary empty baseline
The generated workspace SHALL expose navigable empty roots for Sales, Purchasing, Inventory, and Finance and SHALL NOT invent customer-specific Business Central knowledge.

#### Scenario: Blank BC baseline is generated
- **WHEN** any supported profile is created
- **THEN** `knowledge/bc/sales/`, `knowledge/bc/purchasing/`, `knowledge/bc/inventory/`, and `knowledge/bc/finance/` SHALL each be navigable
- **AND** any managed navigation marker SHALL state that no customer knowledge is recorded

#### Scenario: BC area contains assumed customer behavior
- **WHEN** a generated BC-area file contains process facts, setup values, object IDs, roles, extensions, integrations, requirements, or example transactions presented as customer truth
- **THEN** validation MUST fail closed

### Requirement: Verified immutable release Evidence gates installable workspaces
The future generator SHALL derive `blueprint_version` and `created_with_version` only from one verified installable BCProjectOS release identity and SHALL NOT treat operator input or candidate files as sufficient release Evidence.

#### Scenario: Valid immutable installable release is available
- **WHEN** the expected annotated tag exists, resolves to a concrete release commit, contains a matching final installable manifest, and the released product-scope digest matches that manifest
- **THEN** the command SHALL write the verified manifest version to `blueprint_version` and `created_with_version`
- **AND** the version, tag, resolved commit, manifest commit claims, source commit, installable mode, and digest SHALL be mutually consistent

#### Scenario: Release tag is missing
- **WHEN** no `bcprojectos-v<SemVer>` tag exists for the proposed installable release
- **THEN** customer-workspace generation MUST fail non-zero
- **AND** status SHALL remain `PENDING_BCPROJECTOS_RELEASE`

#### Scenario: Tag resolves to an unexpected commit
- **WHEN** the release tag resolves to a commit other than the commit required by the tagged release Evidence
- **THEN** generation MUST fail closed
- **AND** no workspace or version binding SHALL be published

#### Scenario: Manifest version contradicts the tag
- **WHEN** the manifest release or blueprint version differs from the version encoded in the verified tag name
- **THEN** generation MUST fail closed
- **AND** neither value SHALL be selected by preference or guessing

#### Scenario: Manifest commit contradicts the resolved tag
- **WHEN** a manifest-recorded release commit is missing or differs from the commit resolved from the verified tag, or its source commit is not valid release ancestry
- **THEN** generation MUST fail closed
- **AND** the working tree or Git HEAD MUST NOT substitute for the contradictory commit Evidence

#### Scenario: Product-scope digest does not match
- **WHEN** the SHA-256 digest recomputed from the released product scope at the verified commit differs from the manifest digest
- **THEN** generation MUST fail closed
- **AND** stored checksum or candidate files MUST NOT override the mismatch

#### Scenario: Expected version parameter contradicts release Evidence
- **WHEN** optional `-ExpectedBlueprintVersion` differs from the version proven by the tag and final manifest
- **THEN** the command MUST return non-zero
- **AND** it MUST NOT rewrite, reinterpret, or select either version

#### Scenario: Release candidate exists without a real release tag
- **WHEN** release-candidate manifests, checksums, notes, directories, or validation scripts exist but no verified immutable release tag and final binding exist
- **THEN** they SHALL NOT authorize an installable customer workspace
- **AND** status SHALL remain `PENDING_BCPROJECTOS_RELEASE`

#### Scenario: Release state is unknown or incomplete
- **WHEN** any required tag, commit, manifest field, installable-release claim, ancestry proof, product-scope file, digest, or consistency check is missing, unknown, or contradictory
- **THEN** generation MUST fail non-zero and fail closed
- **AND** no SemVer, tag, commit, digest, installed-release state, or source binding SHALL be fabricated

### Requirement: Pre-release synthetic fixtures remain non-installable
Before verified installable release Evidence exists, the implementation MAY create only clearly marked synthetic development/test fixtures and MUST keep them distinct from customer workspaces.

#### Scenario: Synthetic test run before release
- **WHEN** an authorized test invokes explicit synthetic-fixture mode before a verified installable release exists
- **THEN** output SHALL be confined to a test-owned temporary location and marked `synthetic: true`, `installable: false`, and `PENDING_BCPROJECTOS_RELEASE` in test metadata
- **AND** it SHALL contain no customer, tenant, company, environment, Evidence, approval, or operational data

#### Scenario: Workspace schema requires release-derived SemVer fields
- **WHEN** a pre-release fixture has no verified installable version Evidence but `workspace.schema.json` requires SemVer values
- **THEN** the implementation MUST NOT invent a placeholder or reuse `0.1.0`, a contract-only version, or a release-candidate version
- **AND** the fixture MUST remain explicitly non-installable and MUST NOT pass complete customer-workspace validation until a separate contract decision resolves the fixture representation

#### Scenario: Synthetic fixture is submitted for customer publication
- **WHEN** any caller attempts to publish, install, bind, or report a synthetic fixture as a complete customer workspace
- **THEN** the command and validator MUST fail non-zero
- **AND** no files SHALL be promoted to the requested customer destination

### Requirement: Every generated workspace has exactly one OpenSpec root
The generated customer workspace SHALL contain exactly one OpenSpec root at `<workspace>/openspec/`.

#### Scenario: Blank OpenSpec root is generated
- **WHEN** a valid workspace is created
- **THEN** one generic managed OpenSpec root SHALL exist at `openspec/`
- **AND** it SHALL contain no fabricated customer Change or accepted customer Requirement

#### Scenario: Additional OpenSpec root is detected
- **WHEN** validation finds a project-specific, profile-specific, nested, or second OpenSpec root
- **THEN** validation MUST fail closed

### Requirement: MVP-1 generation remains inside the reduced product boundary
The future generator SHALL remain local-first and SHALL NOT implement or invoke deferred product, platform, customer, or integration capabilities.

#### Scenario: Blank workspace is generated
- **WHEN** the MVP-1 command runs
- **THEN** it SHALL perform only local filesystem operations needed for the blank workspace and validation
- **AND** it SHALL NOT access Business Central, external systems, Project Twin, a control center, network APIs, databases, or publishing endpoints

#### Scenario: Deferred artifact is requested
- **WHEN** input or configuration requests Inbox/OCR processing, productive classification, a full delivery tree, UI, snapshot, synchronization, external publishing, live BC access, or multiple OpenSpec roots
- **THEN** the command MUST reject the request as out of scope

### Requirement: The technical delivery spike remains independent
MVP-1 blank-workspace generation SHALL NOT read from, copy, mutate, execute, or install `examples/bc-enterprise-blueprint/` as a workspace template or runtime dependency.

#### Scenario: MVP-1 implementation is validated
- **WHEN** tests compare protected technical-spike sources before and after generation
- **THEN** their paths and content hashes SHALL remain unchanged
- **AND** the generated workspace SHALL contain no copied spike delivery engine or deliverable tree

### Requirement: Acceptance is deterministic and fail-closed
The future generator and validator SHALL produce deterministic pass/fail results for the same template input, verified release Evidence, and explicit non-version parameters, excluding only declared volatile values such as creation timestamp and newly generated customer ID.

#### Scenario: Equivalent valid requests are evaluated
- **WHEN** equivalent requests use the same profile, alias, verified release Evidence, and contract inputs
- **THEN** their non-volatile tree shape, managed file set, catalog hashes, and controlled content SHALL be identical

#### Scenario: Validator encounters an unknown state
- **WHEN** any required value, file, relation, path, profile, catalog, schema result, or root count is missing, unknown, contradictory, or extra
- **THEN** validation MUST return non-zero
- **AND** it MUST NOT guess, auto-approve, or report readiness

## Release Status

`PENDING_BCPROJECTOS_RELEASE` remains the only valid release status for this specification until independently verified immutable installable release Evidence exists.
