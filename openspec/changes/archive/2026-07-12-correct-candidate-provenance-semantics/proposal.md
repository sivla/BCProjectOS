# Change: Candidate-Provenienz eindeutig von finaler Releasebindung trennen

## Warum
Der Schema-v2-Kandidat belegt die Produktquelle irrefuehrend im Feld `source_commit`, obwohl dieses Feld im finalen Manifest den Promotion-/Release-Quellcommit bezeichnet. Dadurch besitzt dasselbe Feld vor und nach Promotion unterschiedliche Wahrheiten.

## Aenderung
- Neue Kandidaten verwenden Schema 3 und binden ihre unveraenderliche Produktquelle mit `candidate_source_commit` und `candidate_source_tree`.
- `source_commit` und `source_tree` bleiben im Kandidaten `null` und werden erst bei Promotion gesetzt.
- Kandidaten bleiben nicht installierbar und `CONTRACT_REFERENCE_ONLY`.
- Bereits veroeffentlichte finale Schema-1-/Schema-2-Manifeste bleiben pruefbar.

## Nicht-Scope
- Keine Produktfunktion, freie Version, Candidate-Datei, Promotion oder Veroeffentlichung.
