## ADDED Requirements

### Requirement: Hardened project-story validation
Closed work SHALL require acceptance criteria, evidence and a separate closing comment; pages, chronology, worklogs, hypercare and references SHALL be validated.

#### Scenario: Complete story
- **WHEN** all required metadata and references are valid
- **THEN** validation succeeds

#### Scenario: Missing closing comment
- **WHEN** a Done ticket lacks a typed closing comment
- **THEN** validation fails closed
