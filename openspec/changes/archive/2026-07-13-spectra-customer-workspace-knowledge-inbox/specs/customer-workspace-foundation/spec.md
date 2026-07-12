# Kundenworkspace- und Knowledge-Inbox-Fundament

## ADDED Requirements

### Requirement: Ein Workspace repräsentiert genau einen Kunden
Spectra MUST Umgebungen, Gesellschaften, Projekte, Supportfälle, Wissen, Budgets und Lieferverpflichtungen über stabile Kunden- und Scope-Relationen führen.

#### Scenario: Implementation mit Projekt
- **WHEN** ein Implementation-Workspace erzeugt wird
- **THEN** sind Umgebung, Gesellschaft, Projekt, Budget und Verpflichtung referenziell verbunden

#### Scenario: Support ohne Projekt
- **WHEN** ein Support-only-Workspace erzeugt wird
- **THEN** sind direkte Supportfälle, Wissen und Budget ohne künstliches Projekt gültig

### Requirement: Intake bleibt unveränderlich und quellgebunden
Spectra MUST jede aufgenommene Datei über sicheren Pfad, Quellsystem, Objekt-ID, Revision, Größe und SHA-256 binden und doppelte Revisionen idempotent ablehnen.

#### Scenario: Manipulierte Quelle
- **WHEN** Dateiinhalt, Hash oder Revision nicht zur Intake-Evidence passt
- **THEN** lehnt die Inbox den Stand fail-closed ab

### Requirement: Intake erzeugt ausschließlich Vorschläge
Spectra MUST Observations, Vergleiche und Proposals getrennt vom kanonischen Workspacezustand führen und vor einer späteren kontrollierten Planung null Writes garantieren.

#### Scenario: Menschliche Annahme
- **WHEN** eine autorisierte Rolle einen Proposal akzeptiert
- **THEN** bleibt `writes_performed=false` und es entsteht in diesem Block keine automatische Zielmutation

### Requirement: Vergleiche erkennen veraltete Grundlagen
Spectra MUST ComparisonRuns und Proposals an den aktuellen Workspace-Digest binden und veraltete oder konflikthafte Entscheidungen sichtbar blockieren.

#### Scenario: Stale Comparison
- **WHEN** der gebundene Snapshot-Digest nicht mehr dem Workspace entspricht
- **THEN** wird der Proposal nicht als aktuell oder ausführbar akzeptiert
