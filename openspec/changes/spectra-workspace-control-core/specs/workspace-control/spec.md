## ADDED Requirements

### Requirement: Shared profile control core
The product SHALL represent implementation and support-only work with one shared canonical record contract and synthetic isolation.

#### Scenario: Both profiles validate
- **WHEN** both profiles contain valid project, ticket, risk and decision records
- **THEN** the read-only validator succeeds

#### Scenario: Profile boundary is manipulated
- **WHEN** a record claims an unknown profile or customer-specific identity
- **THEN** validation fails closed
