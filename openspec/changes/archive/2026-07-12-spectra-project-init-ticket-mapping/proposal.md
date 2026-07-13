# Change: Projektspezifische Ticketarchitektur im Spectra-Init

## Why
Jedes Projekt kann eine andere Jira- oder Ticketstruktur besitzen. Spectra darf seine empfohlene Standardstruktur deshalb nicht als universellen Vertrag behandeln. Es benötigt ein stabiles fachliches Kernmodell und eine explizite, versionierte Abbildung der jeweiligen Projektstruktur.

## What Changes
- Kanonische Spectra-Kategorien für Arbeit, Defect, Change, Entscheidung, Risiko, Evidence und Support.
- Projektspezifischer Mappingvertrag für Vorgangstypen, Hierarchie und Status.
- Ein auswählbares Spectra-Standardprofil ohne Zwang für Bestandsprojekte.
- Read-only Onboarding validiert jeden vorhandenen Vorgangstyp gegen das Mapping und lehnt unbekannte Typen fail-closed ab.
- Generierte Kollaborationsstruktur bewahrt Projektbegriffe und dokumentiert deren fachliche Spectra-Abbildung.

## Nicht-Scope
- Keine Live-Jira-Konfiguration oder Schreibsynchronisation.
- Keine projektspezifischen Typen, Status oder Kundenwerte im Spectra-Produktpayload.
- Kein Candidate, Tag oder Release in diesem Produktcommit.
