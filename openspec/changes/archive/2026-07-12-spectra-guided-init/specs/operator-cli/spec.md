# Guided Init CLI

## MODIFIED Requirements

### Requirement: Unified dispatcher
Spectra MUST expose deterministic commands for initialization, validation, upgrade planning, upgrade, backup, restore and candidate checking. Initialization MUST accept either an explicit project contract or a guided assistant while preserving dry-run, apply and stable error codes.

#### Scenario: Dry-run command
- **WHEN** an operator invokes a supported command without Apply
- **THEN** no workspace mutation occurs and a machine-readable plan is returned

#### Scenario: Interaktiver Projektstart
- **WHEN** `init -Guided` ohne Answer-Datei aufgerufen wird
- **THEN** fragt Spectra alle verpflichtenden Entscheidungen ab und erzeugt vor Apply einen prüfbaren Plan

#### Scenario: Automatisierbarer geführter Projektstart
- **WHEN** `init -Guided -AnswersPath` verwendet wird
- **THEN** durchläuft dieselbe Konfiguration deterministisch und ohne Konsoleneingabe den Init-Vertrag

#### Scenario: Eigene Ticketstruktur
- **WHEN** eine Projektmapping-Strategie gewählt wird
- **THEN** ist eine explizite versionierte Mappingdatei erforderlich und unbekannte Werte werden fail-closed abgelehnt
