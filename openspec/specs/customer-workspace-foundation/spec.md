# Kundenworkspace- und Knowledge-Inbox-Fundament

## Requirements

### Requirement: Ein Workspace repräsentiert genau einen Kunden
Spectra MUST Umgebungen, Gesellschaften, Projekte, Supportfälle, Wissen, Budgets und Lieferverpflichtungen über stabile Kunden- und Scope-Relationen führen. Support ohne künstliches Projekt ist gültig.

### Requirement: Intake bleibt unveränderlich und quellgebunden
Spectra MUST jede aufgenommene Datei über sicheren Pfad, Quellsystem, Objekt-ID, Revision, Größe und SHA-256 binden und doppelte Revisionen idempotent ablehnen.

### Requirement: Intake erzeugt ausschließlich Vorschläge
Spectra MUST Observations, Vergleiche und Proposals getrennt vom kanonischen Workspacezustand führen und vor einer späteren kontrollierten Planung null Writes garantieren.

### Requirement: Vergleiche erkennen veraltete Grundlagen
Spectra MUST ComparisonRuns und Proposals an den aktuellen Workspace-Digest binden und veraltete oder konflikthafte Entscheidungen sichtbar blockieren.
