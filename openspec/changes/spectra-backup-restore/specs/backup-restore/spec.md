## ADDED Requirements

### Requirement: Safe backup and restore
Backup and restore SHALL be deterministic, hash-bound, path-safe and fail closed without mutating the source.

#### Scenario: Roundtrip
- **WHEN** a valid workspace is backed up and restored to an empty target
- **THEN** file hashes and semantic identity match

#### Scenario: Manipulated backup
- **WHEN** a manifest hash or file is changed
- **THEN** restore aborts without publishing a partial target
