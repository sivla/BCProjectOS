# release-bound-init Specification

## Purpose
TBD - created by archiving change spectra-release-bound-init. Update Purpose after archive.
## Requirements
### Requirement: Reale Projektinitialisierung benötigt eine finale Releasebindung
Spectra MUST einen realen Projektworkspace ausschließlich aus einem finalen, annotiert getaggten und digestgebundenen Release erzeugen.

#### Scenario: Final gebundener Guided Init
- **WHEN** ein Operator Guided Init mit finaler Version, Alias und Apply ausführt
- **THEN** enthält das atomar erzeugte Ziel Releasebindung, Projektvertrag und ausgewählte Blueprints

#### Scenario: Candidate statt Release
- **WHEN** Manifest oder Tag nicht final gebunden ist
- **THEN** bricht Init ab und hinterlässt kein Ziel

### Requirement: Projektlayer wird vor Veröffentlichung des Ziels validiert
Spectra MUST Pfadkollisionen, Profilabweichungen und ungültige Projektkonfigurationen vor dem finalen Move ablehnen.

#### Scenario: Kompositionsfehler
- **WHEN** Basisworkspace und Projektlayer widersprüchliche Pfade oder Profile besitzen
- **THEN** wird der temporäre Stand entfernt und kein gültiger Workspace behauptet

### Requirement: Workspacevalidierung wählt den korrekten read-only Vertrag
Spectra MUST releasegebundene Workspaces mit dem Kundenworkspace-Validator und synthetische Fixtures mit dem Fixturevalidator prüfen.

#### Scenario: Realer Workspace
- **WHEN** `workspace.yaml` und eine Releasebindung vorliegen
- **THEN** delegiert `validate` read-only an `Test-CustomerWorkspace.ps1`
