# candidate-release-binding Specification

## Purpose
TBD - created by archiving change harden-candidate-release-binding. Update Purpose after archive.
## Requirements
### Requirement: Immutable candidate source

Spectra SHALL require every new candidate to bind an explicit full source commit and the exact tree of that commit.

#### Scenario: Bound candidate
- **WHEN** the source commit exists, its tree matches and its Git-blob payload matches manifest and checksums
- **THEN** candidate content validation may pass while publication remains pending

#### Scenario: Missing or false source
- **WHEN** source commit is null, absent, unresolved or its tree differs
- **THEN** validation fails closed

### Requirement: Candidate is not installable

Spectra SHALL require `installable_blueprint=false` and `CONTRACT_REFERENCE_ONLY` for `manifest_state=candidate`.

#### Scenario: Installable candidate claim
- **WHEN** a candidate claims installability or installable consumer mode
- **THEN** validation fails closed

### Requirement: No circular release evidence

The bound source commit SHALL NOT contain its own versioned candidate manifest or checksums.

#### Scenario: Self-referential source
- **WHEN** candidate metadata already exists in the declared source commit
- **THEN** validation fails closed with a stable circularity code

### Requirement: Payload integrity after binding

Manifest and release metadata SHALL remain excluded from the payload digest, and no product payload byte may change between the bound source and candidate commit.

#### Scenario: Payload or digest mutation
- **WHEN** a payload blob, checksum record, count or digest differs
- **THEN** validation fails closed

### Requirement: Explicit compatibility boundary

Spectra SHALL continue to validate immutable schema-v1 final releases but SHALL reject schema-v1 candidates.

#### Scenario: Legacy unbound candidate
- **WHEN** a schema-v1 manifest is in candidate state
- **THEN** validation fails closed and requires regeneration under schema v2
