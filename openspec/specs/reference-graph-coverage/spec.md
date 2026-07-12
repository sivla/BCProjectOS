# reference-graph-coverage Specification

## Purpose
TBD - created by archiving change spectra-reference-graph-coverage. Update Purpose after archive.
## Requirements
### Requirement: Class-based projection accounting

Spectra SHALL account every native relation class exactly once as projected, merged, transformed or explicitly excluded and SHALL validate all per-class and aggregate counts.

#### Scenario: Fully explained non-1:1 projection
- **WHEN** every native relation belongs to exactly one valid mapping and all totals match the source and projection files
- **THEN** explanatory coverage may be complete even when the portable edge count is smaller than the native relation count

#### Scenario: Missing or duplicate mapping
- **WHEN** a native class has no mapping or more than one mapping
- **THEN** validation fails closed with a stable machine-readable code

### Requirement: Controlled transformation and exclusion reasons

Spectra SHALL accept only controlled reason codes whose semantics match the mapping outcome.

#### Scenario: Unexplained exclusion
- **WHEN** an excluded class has no permitted exclusion reason or produces portable edges
- **THEN** validation fails closed

### Requirement: Honest coverage semantics

Spectra SHALL define the denominator as the actual native relation count and the numerator as the exactly accounted native relation count. Spectra SHALL NOT infer one-to-one or complete portable projection from explanatory coverage.

#### Scenario: Invented completeness
- **WHEN** a record asserts one-to-one or complete projection
- **THEN** validation fails closed even if its coverage ratio is one

### Requirement: Read-only hash-bound provenance

Spectra SHALL bind native relations, mapping rules and portable projection through safe relative paths and SHA-256 digests and SHALL validate without modifying them.

#### Scenario: Manipulated bytes or unsafe path
- **WHEN** bytes do not match the recorded digest or any path is absolute, traversing or uses backslashes
- **THEN** validation fails closed

### Requirement: Portable conformance integration

Spectra SHALL expose the validator through the read-only operator CLI and as an explicit optional input to portable full conformance.

#### Scenario: Full conformance with coverage
- **WHEN** a portable story and a coverage workspace are supplied
- **THEN** overall conformance passes only if both contracts pass
