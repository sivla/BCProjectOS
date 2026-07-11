<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->
# UAT Plan

Status: Draft - Not Run

| UAT ID | Requirement | Scenario | Expected Result | Status |
|---|---|---|---|---|
| UAT-001 | REQ-SALES-001 | Approved rule is available | - **WHEN** an eligible sales order is delivered in more than one shipment<br>- **THEN** Business Central SHALL apply the approved shipping cost rule consistently<br>- **AND** the resulting charge SHALL be traceable to the affected order and shipments | Not Run |
| UAT-002 | REQ-SALES-001 | Business rule is not approved | - **WHEN** `BR-SALES-001` has no approved rule content<br>- **THEN** implementation and production activation MUST remain blocked<br>- **AND** no calculation behavior SHALL be invented | Not Run |
| UAT-003 | REQ-SALES-002 | Unauthorized user attempts an exception | - **WHEN** a user without the approved permission attempts to override the shipping cost behavior<br>- **THEN** Business Central SHALL reject the action<br>- **AND** the business document SHALL remain unchanged | Not Run |

Only synthetic or approved anonymized data may be used. No test execution is claimed.
