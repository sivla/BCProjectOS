---
source_id: REQ-SALES-002
ticket_type: Story
parent_epic: EPIC-SALES
status: Draft
external_key: null
---
<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->

# Authorized exception handling

Business Central SHALL restrict shipping cost configuration and approved exceptions to authorized roles.

## Acceptance Criterion: Unauthorized user attempts an exception

- **WHEN** a user without the approved permission attempts to override the shipping cost behavior
- **THEN** Business Central SHALL reject the action
- **AND** the business document SHALL remain unchanged

Source: openspec/changes/control-partial-delivery-shipping-costs/specs/partial-delivery-shipping-cost-control/spec.md
