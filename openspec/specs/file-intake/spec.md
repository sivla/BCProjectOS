# file-intake Specification

## Purpose
TBD - created by archiving change spectra-file-intake. Update Purpose after archive.
## Requirements
### Requirement: Controlled synthetic file intake
The intake SHALL preserve original bytes, bind metadata to SHA-256, quarantine unknown input and support a write-free dry-run.

#### Scenario: Accepted classified file
- **WHEN** classification, sensitivity, hash, size and references are valid
- **THEN** metadata is accepted without changing original bytes

#### Scenario: Unsafe or manipulated file
- **WHEN** a path escapes, a hash differs or classification is unknown
- **THEN** intake fails closed or quarantines the record
