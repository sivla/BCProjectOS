# Specification: Generischer Blueprint-Katalog

## ADDED Requirements

### Requirement: Versionierter Katalog
Der Katalog MUST drei generische Blueprint-Typen mit stabiler Version und Provenienz enthalten. Kundenwerte und echte Evidence MUST NOT enthalten sein.

#### Scenario: Katalogauswahl
- WHEN ein synthetischer Workspace einen Implementierungs-, Support- oder BC-Basic-Blueprint anfordert
- THEN wird genau der versionierte Blueprint mit Provenienz vorgeschlagen.

### Requirement: Variable Struktur
Blueprints MUST variable Module, Seiten und Tickets erlauben. Die Jira-Hierarchie MUST Phase, Epic, Story/Bug und Task unterscheiden; nur Task darf `billable=true` tragen.

#### Scenario: Variable Tickets
- WHEN eine Vorschau unterschiedlich viele Stories und Tasks enthaelt
- THEN wird sie ohne Mengenannahme validiert und nur Tasks als abrechenbar akzeptiert.

### Requirement: Proposal-only Bootstrap
Eine Vorschau MUST nur Inbox-/Proposal-Artefakte und einen deterministischen Diff erzeugen. Direkte Jira-, Confluence- oder Dateimutationen sind verboten.

#### Scenario: Read-only Vorschau
- WHEN ein Blueprint gegen eine vorhandene Zielrevision verglichen wird
- THEN bleiben Zielartefakte byte- und semantisch unveraendert und ein Diff-Proposal entsteht.

### Requirement: Fail-closed Validierung
Unbekannter Blueprint, fehlende Provenienz, Kundenwissen, feste Kardinalitaet, leere Pflichtseite, billable Non-Task, unsichere Referenz und ID-Konflikt MUST mit stabilen Fehlercodes abgelehnt werden.

#### Scenario: Fehlerhafte Vorlage
- WHEN eine Vorlage einen unbekannten Blueprint oder eine billable Story enthaelt
- THEN wird sie mit dem passenden stabilen Fehlercode abgelehnt.

### Requirement: Idempotenz und Connectorgrenze
Gleicher Blueprintstand und gleiche Zielrevision MUST denselben Vorschau-Digest ergeben. Live-Connectoren und Secrets sind ausserhalb dieses Changes.

#### Scenario: Wiederholte Vorschau
- WHEN dieselbe Eingabe zweimal dry-run ausgefuehrt wird
- THEN sind Vorschau und Digest identisch und es erfolgt kein externer Zugriff.
