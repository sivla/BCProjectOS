# Referenzgraph-Projektion und Coverage

Spectra unterscheidet native Relationen von portablen Kanten. Eine native Relation darf direkt projiziert, mit anderen Relationen zusammengeführt, in eine andere portable Relationsklasse transformiert oder kontrolliert ausgeschlossen werden. Eine kleinere portable Kantenmenge ist deshalb kein Verlustnachweis, solange jede native Relation genau einer geprüften Erklärung zugeordnet ist.

Die Coverage-Semantik lautet `explained-native-relations`: Der Nenner ist die tatsächliche native Relationsmenge, der Zähler die eindeutig zugeordnete native Relationsmenge. Ein Verhältnis von `1` behauptet ausdrücklich weder eine 1:1-Abbildung noch eine vollständige portable Repräsentation.

Der Vertrag `schemas/reference-graph-coverage.schema.json` bindet Quellgraph, Mappingregeln und portable Projektion über sichere relative Pfade und SHA-256. Der Validator arbeitet ausschließlich read-only. Unbekannte Gründe, unklare Exklusionen, doppelte Zuordnungen, falsche Summen, unsichere Pfade und manipulierte Bytes werden fail-closed abgelehnt.

Operatorprüfung:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 -Command validate-graph-coverage -Workspace <workspace>
```
