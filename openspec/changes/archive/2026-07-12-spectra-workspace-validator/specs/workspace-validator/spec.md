## ADDED Requirements

### Requirement: Read-only validation

The validator SHALL validate an installed Spectra customer workspace without modifying it.

#### Scenario: Valid installed workspace
- **WHEN** a workspace has valid schema, profile, catalogs, one OpenSpec root, and a verified BOUND release
- **THEN** validation succeeds

#### Scenario: Catalog drift
- **WHEN** a managed catalog differs from the product catalog
- **THEN** validation fails closed and leaves the workspace unchanged
