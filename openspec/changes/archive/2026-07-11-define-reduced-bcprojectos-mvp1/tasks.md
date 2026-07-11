## 1. Generator Contract and Safe Creation

- [ ] 1.1 Implement the single `automation/New-CustomerWorkspace.ps1` entry point with explicit destination, profile, non-sensitive alias, optional expected-version comparison, and an explicit test-only synthetic-fixture mode.
- [ ] 1.2 Implement resolved-root, path-traversal, and Windows reparse-point containment checks before creating or publishing files.
- [ ] 1.3 Implement sibling staging, complete pre-publish validation, atomic local rename, and cleanup limited to invocation-owned staging.
- [ ] 1.4 Add negative tests proving non-empty destinations and existing files are never overwritten or deleted.

## 2. Canonical Blank Workspace

- [ ] 2.1 Implement the exact high-level structure from `contract/workspace-architecture.md` without adding fake operational records.
- [ ] 2.2 Generate `workspace.yaml` and validate it against `schemas/workspace.schema.json`, including self-namespaced `CUS-*` identity and exactly one OpenSpec root.
- [ ] 2.3 Add `governance/policies/workspace-profile.yaml` with the controlled `implementation`, `support-only`, and `mixed` values outside canonical `workspace.yaml`.
- [ ] 2.4 Copy the complete `catalogs/` file set into `governance/catalogs/` and verify exact names and SHA-256 hashes.
- [ ] 2.5 Add fact-free navigation roots for Sales, Purchasing, Inventory, and Finance.

## 3. Honest Empty Profiles and Version State

- [ ] 3.1 After verified installable release Evidence exists, add positive workspace fixtures for all three profiles proving the same canonical blank structure with only controlled profile differences.
- [ ] 3.2 Add negative tests rejecting fabricated projects, support cases, meetings, tickets, Requirements, Changes, Evidence, approvals, UAT, training, release, customer facts, and generated delivery records.
- [ ] 3.3 Derive version only from verified tag/externally-resolved-tag-commit/final-installable-manifest/digest Evidence; allow an expected-version parameter only as an exact comparison and prove no version is inferred from `0.1.0`, Git HEAD, roadmap text, working-tree state, candidate directories, or checksums alone.
- [x] 3.4 Resolve the pre-release fixture/schema contract decision: do not invent SemVer, distinguish historical versioned evidence from new synthetic fixtures, and ensure synthetic fixtures cannot pass customer-workspace validation.
- [ ] 3.5 Add fail-closed tests for missing tag, unexpected tag commit, tag/manifest version mismatch, invalid source ancestry, product-scope digest mismatch, expected-version mismatch, and unknown/incomplete release state.
- [x] 3.6 Add synthetic-mode gates proving pre-release fixtures are test-only, contain no customer or Evidence data, retain `PENDING_BCPROJECTOS_RELEASE`, and cannot be reported as customer workspaces.
- [x] 3.7 Define `schemas/consumer-binding.schema.json` plus read-only validator and deterministic pending/negative fixtures; require repository verification before accepting `BOUND`.

## 4. Deterministic Fail-Closed Validation

- [ ] 4.1 Implement a read-only MVP-1 workspace validator for required paths, schema, IDs, profile, catalogs, BC areas, empty collections, OpenSpec-root count, sensitive-value patterns, and complete immutable release Evidence.
- [ ] 4.2 Add deterministic positive tests comparing non-volatile tree shape, managed files, catalog hashes, and controlled content across equivalent requests.
- [ ] 4.3 Add negative fixtures for missing paths, path escape, reparse-point escape, invalid schema, catalog drift, unknown profile, second OpenSpec root, deferred-feature requests, partial generation failure, and synthetic-fixture publication attempts.
- [ ] 4.4 Prove generator and validator perform no network, external-system, Project-Twin, database, UI, publishing, or live Business Central action.
- [ ] 4.5 Prove `examples/bc-enterprise-blueprint/` sources remain byte-identical.

## 5. MVP-1 Acceptance

- [ ] 5.1 Run the complete MVP-0 product-contract regression and the new MVP-1 positive and negative suite.
- [ ] 5.2 Run OpenSpec validation for this change and resolve specification errors without archiving any change.
- [ ] 5.3 Run `git diff --check`, a diff-scoped secret/tenant scan, and `git status --short`.
- [ ] 5.4 Record the exact command contract, validation evidence, intentional non-goals, and remaining `PENDING_BCPROJECTOS_RELEASE` status in the MVP-1 implementation handoff.
