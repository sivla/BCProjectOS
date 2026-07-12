# Change: Geführte Projektinitialisierung und Bestands-Onboarding

## Why
Spectra kann veröffentlichte Workspaces sicher erzeugen, verlangt für einen neuen Projekteinstieg aber noch zu viel verborgenes Operatorwissen. Ein PM oder Consultant braucht einen klaren Einstieg für ein neues BC-Basic-Projekt und für die read-only Bestandsaufnahme eines vorhandenen Projektbereichs.

## What Changes
- Ein geführter, maschinenlesbarer Init-Vertrag für `new`, `local` und `onboard`.
- Immer genau ein zentraler Projekt-Space sowie optionale, nur referenzierte Wissensbereiche.
- Portable Jira-/Confluence-Zielstrukturen ohne Live-Zugang und ohne gespeicherte Secrets.
- Read-only Onboarding aus einem expliziten dateibasierten Export mit Inventar, Hashes und Mappingentscheidungen.
- Dry-run als Standard und atomarer Apply in ein leeres Ziel.

## Nicht-Scope
- Keine Live-Jira-/Confluence-Verbindung und keine Schreibsynchronisation.
- Keine Site-URLs, Space-Schlüssel, Tokens oder Kundeninhalte im Spectra-Produktpayload.
- Keine Änderung am veröffentlichten `1.0.0-rc.1`.
- Kein Tag, Release oder Versionsversprechen in diesem Change.
