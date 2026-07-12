# Guided Init CLI

## MODIFIED Requirements

### Requirement: Die Operator-CLI delegiert reale Produktfunktionen
Die Spectra-Operator-CLI MUST für Init entweder einen expliziten Projektvertrag oder einen geführten Assistenten verwenden und MUST Dry-run, Apply und stabile Fehlercodes beibehalten.

#### Scenario: Interaktiver Projektstart
- **WHEN** `init -Guided` ohne Answer-Datei aufgerufen wird
- **THEN** fragt Spectra alle verpflichtenden Entscheidungen ab und erzeugt vor Apply einen prüfbaren Plan

#### Scenario: Automatisierbarer geführter Projektstart
- **WHEN** `init -Guided -AnswersPath` verwendet wird
- **THEN** durchläuft dieselbe Konfiguration deterministisch und ohne Konsoleneingabe den Init-Vertrag

#### Scenario: Eigene Ticketstruktur
- **WHEN** eine Projektmapping-Strategie gewählt wird
- **THEN** ist eine explizite versionierte Mappingdatei erforderlich und unbekannte Werte werden fail-closed abgelehnt
