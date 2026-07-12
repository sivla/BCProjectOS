# Adapter Provenance

## ADDED Requirements

### Requirement: Hash-bound read-only source projection

Spectra SHALL define adapter provenance with a stable provenance ID, profile, safe source blob path, source SHA-256, mapping version, safe projection path and projection SHA-256.

#### Scenario: Valid projection
- **WHEN** actual source and projection bytes match their recorded SHA-256 values
- **THEN** validation succeeds without modifying either file

#### Scenario: Manipulated bytes
- **WHEN** source or projection bytes differ from their recorded digest
- **THEN** validation fails closed with a stable hash error code

### Requirement: Source-of-truth and write protection

The source SHALL remain the declared source of truth, before/after source hashes SHALL match, and the contract SHALL deny source writes and overwrite permission.

#### Scenario: Read-only adapter
- **WHEN** source mode is `read-only`, writes performed is false, projection-only is true and overwrite allowed is false
- **THEN** the provenance may validate

#### Scenario: Source mutation or write claim
- **WHEN** before/after hashes differ or any source write/overwrite is claimed
- **THEN** validation fails closed

### Requirement: Safe portable paths

Source and projection paths SHALL be distinct, repository-relative forward-slash paths beneath the explicit workspace root.

#### Scenario: Unsafe path
- **WHEN** a path is absolute, traverses upward, uses a backslash, or resolves outside the root
- **THEN** validation fails before reading the target
