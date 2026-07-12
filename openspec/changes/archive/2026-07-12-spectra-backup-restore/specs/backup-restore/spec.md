## ADDED Requirements

### Requirement: Safe backup and restore
Backup and restore SHALL be deterministic, hash-bound, path-safe and fail closed without mutating the source.

#### Scenario: Roundtrip
- **WHEN** a valid workspace is backed up and restored to an empty target
- **THEN** file hashes and semantic identity match

#### Scenario: Manipulated backup
- **WHEN** a manifest hash or file is changed
- **THEN** restore aborts without publishing a partial target

#### Scenario: Release delta
- **WHEN** the backup/restore block is compared with published `0.4.0-alpha.1`
- **THEN** `0.5.0-alpha.1` is the proposed candidate scope and no 1.0 readiness is claimed
