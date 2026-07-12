# Candidate Evidence

## MODIFIED Requirements

### Requirement: Candidate-Evidence bindet die unveränderliche Produktquelle
Ein neuer Spectra-Candidate MUST Produktcommit, Produkttree, vollständige Payloadliste, Dateimodi, Größen und SHA-256-Digest binden und MUST bis zur getrennten Promotion nicht installierbar bleiben.

#### Scenario: Zweiter 1.0 Release Candidate
- **WHEN** der additive Init-/Onboarding-Vertrag aus einem commitgebundenen Produktstand als `1.0.0-rc.2` vorbereitet wird
- **THEN** sind Candidate-Provenienz und Payload vollständig gebunden, finale Source-Felder null und der Status PENDING
