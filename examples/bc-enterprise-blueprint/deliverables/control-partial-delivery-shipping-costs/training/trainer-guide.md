<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->
# Trainer Guide

Use the approved business rule, verified BC build, UAT plan, and exercises. Screenshots and timings remain blocked until the implementation is stable.

## Exercise UAT-001 - Approved rule is available

Requirement: $(@{id=REQ-SALES-001; title=Configured shipping cost rule is applied consistently; description=Business Central SHALL apply the approved shipping cost rule to partial and subsequent deliveries for an eligible sales order. The exact calculation rule SHALL be defined by the approved `BR-SALES-001` before implementation.; scenarios=System.Object[]; sourcePath=openspec/changes/control-partial-delivery-shipping-costs/specs/partial-delivery-shipping-cost-control/spec.md}.id)`r

Steps: To be finalized against the verified BC build.

Expected behavior:

- **WHEN** an eligible sales order is delivered in more than one shipment
- **THEN** Business Central SHALL apply the approved shipping cost rule consistently
- **AND** the resulting charge SHALL be traceable to the affected order and shipments

Result: Not Run

## Exercise UAT-002 - Business rule is not approved

Requirement: $(@{id=REQ-SALES-001; title=Configured shipping cost rule is applied consistently; description=Business Central SHALL apply the approved shipping cost rule to partial and subsequent deliveries for an eligible sales order. The exact calculation rule SHALL be defined by the approved `BR-SALES-001` before implementation.; scenarios=System.Object[]; sourcePath=openspec/changes/control-partial-delivery-shipping-costs/specs/partial-delivery-shipping-cost-control/spec.md}.id)`r

Steps: To be finalized against the verified BC build.

Expected behavior:

- **WHEN** `BR-SALES-001` has no approved rule content
- **THEN** implementation and production activation MUST remain blocked
- **AND** no calculation behavior SHALL be invented

Result: Not Run

## Exercise UAT-003 - Unauthorized user attempts an exception

Requirement: $(@{id=REQ-SALES-002; title=Authorized exception handling; description=Business Central SHALL restrict shipping cost configuration and approved exceptions to authorized roles.; scenarios=System.Object[]; sourcePath=openspec/changes/control-partial-delivery-shipping-costs/specs/partial-delivery-shipping-cost-control/spec.md}.id)`r

Steps: To be finalized against the verified BC build.

Expected behavior:

- **WHEN** a user without the approved permission attempts to override the shipping cost behavior
- **THEN** Business Central SHALL reject the action
- **AND** the business document SHALL remain unchanged

Result: Not Run
