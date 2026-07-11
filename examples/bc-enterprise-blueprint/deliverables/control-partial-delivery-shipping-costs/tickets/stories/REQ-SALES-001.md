---
source_id: REQ-SALES-001
ticket_type: Story
parent_epic: EPIC-SALES
status: Draft
external_key: null
---
<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->

# Configured shipping cost rule is applied consistently

Business Central SHALL apply the approved shipping cost rule to partial and subsequent deliveries for an eligible sales order. The exact calculation rule SHALL be defined by the approved `BR-SALES-001` before implementation.

## Acceptance Criterion: Approved rule is available

- **WHEN** an eligible sales order is delivered in more than one shipment
- **THEN** Business Central SHALL apply the approved shipping cost rule consistently
- **AND** the resulting charge SHALL be traceable to the affected order and shipments

## Acceptance Criterion: Business rule is not approved

- **WHEN** `BR-SALES-001` has no approved rule content
- **THEN** implementation and production activation MUST remain blocked
- **AND** no calculation behavior SHALL be invented

Source: openspec/changes/control-partial-delivery-shipping-costs/specs/partial-delivery-shipping-cost-control/spec.md
