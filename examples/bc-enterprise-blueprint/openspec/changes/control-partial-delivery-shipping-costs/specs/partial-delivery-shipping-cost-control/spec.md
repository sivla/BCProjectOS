## ADDED Requirements

### Requirement: REQ-SALES-001 - Configured shipping cost rule is applied consistently

Business Central SHALL apply the approved shipping cost rule to partial and subsequent deliveries for an eligible sales order. The exact calculation rule SHALL be defined by the approved `BR-SALES-001` before implementation.

#### Scenario: Approved rule is available

- **WHEN** an eligible sales order is delivered in more than one shipment
- **THEN** Business Central SHALL apply the approved shipping cost rule consistently
- **AND** the resulting charge SHALL be traceable to the affected order and shipments

#### Scenario: Business rule is not approved

- **WHEN** `BR-SALES-001` has no approved rule content
- **THEN** implementation and production activation MUST remain blocked
- **AND** no calculation behavior SHALL be invented

### Requirement: REQ-SALES-002 - Authorized exception handling

Business Central SHALL restrict shipping cost configuration and approved exceptions to authorized roles.

#### Scenario: Unauthorized user attempts an exception

- **WHEN** a user without the approved permission attempts to override the shipping cost behavior
- **THEN** Business Central SHALL reject the action
- **AND** the business document SHALL remain unchanged
