# Design

## Context

The behavioral boundary is specified, but the governing business rule and current BC extension landscape are incomplete.

## Goals

- Apply one approved rule consistently.
- Preserve traceability from business rule to BC behavior and tests.
- Restrict configuration and exceptions by permission.

## Non-Goals

- Selecting the business rule on behalf of the Process Owner.
- Naming AL objects before the existing solution is inspected.
- Deploying to a live environment.

## Functional Design

The final design shall identify eligible orders, the point of calculation, document behavior, corrections, returns, and permitted exceptions after `BR-SALES-001` is approved.

## Technical Design

TBD after symbol and source inspection: setup storage, event subscribers, posting integration, Permission Set, telemetry, AL tests, object IDs and upgrade behavior.

## Data and Security

No customer-specific test data is required. Configuration and exception permissions must be separate where segregation of duties requires it.

## Integration Impact

Unknown until the integration catalog and existing extensions are completed.

## Upgrade, Deployment, and Rollback

TBD after implementation design. Activation must default to disabled until configuration is approved.

## Risks

- Incomplete rule could create incorrect charges: implementation remains blocked.
- Duplicate calculation during posting: cover posting and retry paths with automated tests.
- Manual exception bypass: enforce permissions and auditability.

## Decisions Required

- Approve `BR-SALES-001`.
- Confirm charge source and accounting treatment.
- Confirm exception roles and correction behavior.
