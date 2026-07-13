# Kundenworkspace- und Knowledge-Inbox-Fundament

## Purpose

Dieser Vertrag definiert die isolierte Kunden- und Scopegrundlage sowie den unveraenderlichen, proposal-only Wissenseingang ohne direkte Zielmutation.

## Requirements

### Requirement: Ein Workspace repräsentiert genau einen Kunden
Spectra MUST Umgebungen, Gesellschaften, Projekte, Supportfälle, Wissen, Budgets und Lieferverpflichtungen über stabile Kunden- und Scope-Relationen führen. Support ohne künstliches Projekt ist gültig.

#### Scenario: Support-only-Kunde
- **WHEN** ein Kundenworkspace ausschliesslich Supportfaelle besitzt
- **THEN** bleibt er ohne erfundenes Projekt gueltig

### Requirement: Intake bleibt unveränderlich und quellgebunden
Spectra MUST jede aufgenommene Datei über sicheren Pfad, Quellsystem, Objekt-ID, Revision, Größe und SHA-256 binden und doppelte Revisionen idempotent ablehnen.

#### Scenario: Doppelte Quellrevision
- **WHEN** dieselbe Objekt-ID, Revision und derselbe Hash erneut aufgenommen werden
- **THEN** entsteht kein zweites Intake-Objekt

### Requirement: Intake erzeugt ausschließlich Vorschläge
Spectra MUST Observations, Vergleiche und Proposals getrennt vom kanonischen Workspacezustand führen und vor einer späteren kontrollierten Planung null Writes garantieren.

#### Scenario: Proposal ohne Freigabe
- **WHEN** ein Proposal erzeugt oder geprueft wird
- **THEN** bleiben alle kanonischen Zielartefakte unveraendert

### Requirement: Vergleiche erkennen veraltete Grundlagen
Spectra MUST ComparisonRuns und Proposals an den aktuellen Workspace-Digest binden und veraltete oder konflikthafte Entscheidungen sichtbar blockieren.

#### Scenario: Veralteter Workspace-Digest
- **WHEN** der gebundene Workspace-Digest nicht mehr dem aktuellen Stand entspricht
- **THEN** wird die Entscheidung als stale blockiert
