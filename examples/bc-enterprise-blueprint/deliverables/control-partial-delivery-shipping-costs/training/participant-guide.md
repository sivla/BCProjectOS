<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->
# Participant Guide

Purpose: Betroffene Rollen wenden die freigegebene Versandkostenregel bei Teil- und Nachlieferungen sicher an.

## REQ-SALES-001 - Configured shipping cost rule is applied consistently

Business Central SHALL apply the approved shipping cost rule to partial and subsequent deliveries for an eligible sales order. The exact calculation rule SHALL be defined by the approved `BR-SALES-001` before implementation.

## REQ-SALES-002 - Authorized exception handling

Business Central SHALL restrict shipping cost configuration and approved exceptions to authorized roles.
