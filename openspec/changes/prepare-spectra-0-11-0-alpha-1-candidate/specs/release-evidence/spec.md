## ADDED Requirements

### Requirement: Spectra 0.11.0-alpha.1 bleibt ein ehrlicher PENDING-Candidate
Der Candidate MUST ausschließlich die unveraenderliche Produktquelle ueber `candidate_source_commit` und `candidate_source_tree` binden. Finale Source-Felder MUST null bleiben, und der Candidate MUST nicht installierbar sein.

#### Scenario: Candidate-Evidence
- **WHEN** die Candidate-Evidence fuer 0.11.0-alpha.1 erzeugt und geprueft wird
- **THEN** stimmen Git-Blob-Payload, Checksums und Digest reproduzierbar ueberein

#### Scenario: Keine Veroeffentlichungsbehauptung
- **WHEN** der Candidate ohne getrennte Promotion vorliegt
- **THEN** bleiben Status PENDING, Consumer-Modus CONTRACT_REFERENCE_ONLY und Installierbarkeit false
