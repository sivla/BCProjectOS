# Portable Conformance Contract

## ADDED Requirements

### Requirement: Explicit portable validation
The validator MUST accept the story root only through an explicit parameter and remain read-only.

#### Scenario: Foreign workspace
- **WHEN** a temporary external story directory is supplied
- **THEN** the validator reads and validates it without product-root assumptions

### Requirement: Complete story conformance
The validator MUST validate identity, offers, project period, pages, tickets, timeline domains, hypercare, costs and exact inverse graph edges.

#### Scenario: Valid synthetic BC story
- **WHEN** the 3-offer, 19-page, 17-ticket fixture is supplied
- **THEN** conformance passes with deterministic output

### Requirement: Fail closed
The validator MUST reject unsafe paths, metadata mismatches, period violations, invalid status history, open P1/P2 at exit, cost mismatches and missing inverse edges.

#### Scenario: Manipulated story
- **WHEN** one required field or relation is altered
- **THEN** a stable German error code is returned and no mutation occurs
