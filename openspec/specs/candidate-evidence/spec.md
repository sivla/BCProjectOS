# candidate-evidence Specification

## Purpose
TBD - created by archiving change prepare-spectra-0-10-0-alpha-1-candidate. Update Purpose after archive.
## Requirements
### Requirement: Exact source-bound candidate

The `0.10.0-alpha.1` candidate SHALL bind the approved merge commit, its exact tree, 110 payload Git blobs and their deterministic SHA-256 bundle digest.

#### Scenario: Candidate evidence matches source
- **WHEN** commit, tree, file list, sizes, blob hashes and bundle digest are recomputed
- **THEN** all values match the stored candidate evidence

### Requirement: Candidate remains non-installable

The candidate SHALL use schema v2, candidate state, contract-reference-only mode and `installable_blueprint=false`.

#### Scenario: Installation or publication claim
- **WHEN** the candidate is presented without final promotion, annotated tag and release verification
- **THEN** installation and publication remain fail-closed

### Requirement: Evidence is outside product payload

Candidate files and OpenSpec evidence SHALL NOT change the 110-file product payload bound to the source commit.

#### Scenario: Candidate commit verification
- **WHEN** source and candidate-commit payload records are compared
- **THEN** they are byte-identical while release metadata remains excluded
