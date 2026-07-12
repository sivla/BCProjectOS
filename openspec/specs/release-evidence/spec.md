# release-evidence Specification

## Purpose
TBD - created by archiving change correct-candidate-provenance-semantics. Update Purpose after archive.
## Requirements
### Requirement: Kandidaten- und Finalprovenienz sind semantisch getrennt
Ein Schema-3-Kandidat MUST seine Produktquelle mit `candidate_source_commit` und `candidate_source_tree` binden. `source_commit` und `source_tree` MUST im Kandidaten null sein. Erst die Promotion MUST die Kandidatenbindung verifizieren und ein finales Manifest mit `source_commit` und `source_tree` erzeugen.

#### Scenario: Gebundener PENDING-Kandidat
- **WHEN** ein Kandidat aus einem unveraenderlichen Produktcommit erzeugt wird
- **THEN** ist er Schema 3, nicht installierbar und bindet nur `candidate_source_commit/tree`

#### Scenario: Promotion
- **WHEN** ein gueltiger Kandidat promoviert wird
- **THEN** werden Kandidatenfelder entfernt und finale `source_commit/tree` gesetzt

#### Scenario: Residuale Kandidatenprovenienz im Finalmanifest
- **WHEN** ein finales Manifest nichtleere `candidate_source_commit/tree`-Werte enthaelt
- **THEN** wird es fail-closed abgelehnt

#### Scenario: Irrefuehrender Kandidat
- **WHEN** ein Kandidat finale Source-Felder fuellt oder seine Kandidatenprovenienz manipuliert
- **THEN** wird er fail-closed abgelehnt

#### Scenario: Bestehendes finales Manifest
- **WHEN** ein veroeffentlichtes finales Schema-1- oder Schema-2-Manifest geprueft wird
- **THEN** bleibt es kompatibel pruefbar

