# Generische Dokument- und Jira-Projektion

## ADDED Requirements

### Requirement: Dokumentation ist beliebig hierarchisch
Spectra MUST 1..N Spaces, beliebig viele Rootknoten und explizite Home-Referenzen ohne feste Kunden- oder Projekttopologie validieren.

#### Scenario: Support ohne Projekt
- **WHEN** eine Support-/Knowledge-Projektion keine Tickets enthält
- **THEN** bleibt die Dokumentation unabhängig gültig und darstellbar

### Requirement: Generierte und authored Inhalte bleiben getrennt
Spectra MUST generierte Dokumente vollständig an Blueprint, Quellrevisionen, Snapshot, Digest und Erzeugungszeit binden und authored Dokumente als führende menschliche Inhalte vor Überschreibung schützen.

#### Scenario: Doppelte führende Wahrheit
- **WHEN** ein generiertes Dokument eine konkurrierende authored Sektion behauptet
- **THEN** lehnt der Validator die Projektion fail-closed ab

### Requirement: Referenzen und Provenienz sind fail-closed
Spectra MUST Zyklen, doppelte IDs oder Orders, unbekannte Parents/Dokumente, Cross-Customer-Referenzen, unsichere Origins und fehlende Provenienz ablehnen.

#### Scenario: Ungültiger Referenzgraph
- **WHEN** eine Projektion einen Zyklus, unbekannten Endpunkt oder fremden Kunden referenziert
- **THEN** endet die Validierung mit einem stabilen Fehlercode und ohne Mutation

### Requirement: Renderer bleibt lokal und deterministisch
Spectra MUST gleiche validierte Eingaben byteidentisch in einem neuen lokalen Ziel rendern und darf bestehende authored Dateien nicht überschreiben.

#### Scenario: Wiederholtes Rendering
- **WHEN** derselbe validierte Snapshot zweimal in neue Ziele gerendert wird
- **THEN** sind die generierten Dateien byteidentisch und authored Pfade bleiben ungeschrieben
