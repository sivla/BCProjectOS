# Design

## Semantik

Der Nenner ist die tatsächliche Anzahl nativer Relationen. Der Zähler ist die Anzahl nativer Relationen, die genau einer überprüften Klassenabbildung zugeordnet sind. Eine Abbildung kann `projected`, `merged`, `transformed` oder `excluded` sein. Daher kann `coverage_ratio = 1` gelten, obwohl weniger portable Kanten existieren. `one_to_one_claim` und `complete_projection_claim` bleiben verbindlich `false`.

## Deterministische Zuordnung

Jede native Relationsklasse erscheint genau einmal in den Mappingregeln. Jede Regel bindet native Klasse, optionale portable Klasse, Outcome, native Menge, portable Kantenmenge und einen kontrollierten Reason-Code. Exklusionen benötigen einen expliziten Exklusionsgrund und erzeugen keine portable Kante. Doppelte oder fehlende Klassenzuordnungen sind unzulässig.

## Integrität und Grenze

Quellrelationen, Mappingregeln und Projektion liegen unter einem expliziten Workspace-Root. Nur repository-relative Vorwärtspfade sind erlaubt. SHA-256 bindet die tatsächlichen Dateibytes. Der Validator arbeitet read-only und verlangt unveränderte Quelle, `writes_performed=false` sowie `projection_only=true`.

## Integration

`Test-ReferenceGraphCoverage.ps1` ist der fachliche Validator. `Invoke-Spectra.ps1 -Command validate-graph-coverage` stellt ihn read-only bereit. `Invoke-PortableFullConformance.ps1` kann denselben Vertrag über einen expliziten `CoveragePath` obligatorisch ergänzen, ohne ältere portable Story-Workspaces zu brechen.

## Releaseeinordnung

Die vollständig grüne Funktions- und Regressionsstrecke belegt eine neue additive, rückwärtskompatible Produktfähigkeit gegenüber `0.9.0-alpha.1`. Der policy-konforme Vorschlag für einen später getrennt zu erzeugenden Candidate lautet deshalb `0.10.0-alpha.1`: Minor-Schritt wegen des neuen Coverage-Vertrags, weiterhin Alpha wegen noch ausstehender 1.0-RC-/Pilot-Evidence. Dieser Change erzeugt selbst kein Versionsmanifest und keine Releasebehauptung.

Der veröffentlichte 0.9-Payload umfasst 102 Dateien. Der Entwicklungsstand umfasst 109 Payloaddateien; die sieben zusätzlichen Produktdateien sind Schema, Vertrag, Generator, Validator, Exact-Runner sowie positive und negative Tests.
