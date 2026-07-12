# Project Reconciliation

## ADDED Requirements

### Requirement: Versioned baseline, offer and actual reconciliation

Spectra SHALL define a closed machine-readable reconciliation contract containing stable identity, profile, contract version, versioned baseline, offer and actual values, and calculated variances for hours, rate and amount.

#### Scenario: Consistent reconciliation
- **WHEN** each amount equals hours multiplied by rate and all variances equal actual minus offer
- **THEN** the read-only validator succeeds without changing the record

#### Scenario: Arithmetic mismatch
- **WHEN** an amount or variance contradicts its source values
- **THEN** validation fails closed with a stable reconciliation error code

### Requirement: Explicit truth boundary

The reconciliation SHALL state whether it is a synthetic fixture or customer-owned workspace truth and SHALL explicitly deny invoice and productive-activity claims.

#### Scenario: Synthetic example
- **WHEN** classification is `synthetic-fixture`, synthetic is true, and invoice/productive claims are false
- **THEN** the example may validate without becoming customer Evidence

#### Scenario: Unsupported claim
- **WHEN** the record claims an invoice, productive activity, or an unknown truth owner
- **THEN** validation fails closed

### Requirement: Explained variance

Every non-zero hours, rate or amount variance SHALL carry a controlled reason code and a non-empty explanation.

#### Scenario: Unexplained variance
- **WHEN** any variance is non-zero and no admissible reason is present
- **THEN** validation fails with `RECONCILIATION_VARIANCE_REASON_REQUIRED`
