# blueprint-catalog Specification

## Purpose

Der Blueprint-Katalog definiert wiederverwendbare, kundenunabhaengige Ausgangsstrukturen. Der V2-Vertrag ist fuer neue Vorschauen fuehrend; der kuratierte V1-Katalog bleibt ausschließlich als kompatible Herkunft fuer bestehende Init-Auswahlen erhalten.

## Requirements

### Requirement: Versionierter Katalog

Der Katalog MUST Implementierungs-, Support- und BC-Basic-Blueprints mit stabiler Version, Provenienz, Zweck, fuehrendem Ablageort, Feldern, Referenzen und Inhaltsgrenzen enthalten. Kundenwerte, Secrets, simulierte Abnahmen und echte Evidence MUST NOT enthalten sein.

#### Scenario: Katalogauswahl

- **WHEN** ein synthetischer Workspace einen Implementierungs-, Support- oder BC-Basic-Blueprint anfordert
- **THEN** wird genau der versionierte Blueprint mit Provenienz vorgeschlagen

### Requirement: Variable und schlanke Struktur

Blueprints MUST variable Module, Seiten und Tickets erlauben. Die Jira-Hierarchie MUST Phase, Epic, Story oder Bug und Task unterscheiden; nur Task darf `billable=true` tragen. Nur explizit referenzierte Seitengruppen duerfen vorgeschlagen werden, und leere optionale Seiten duerfen nicht erzwungen werden.

#### Scenario: Variable Tickets und Seiten

- **WHEN** eine Vorschau unterschiedlich viele Stories, Bugs, Tasks und inhaltlich benoetigte Seiten enthaelt
- **THEN** wird sie ohne Mengenannahme validiert und nur Tasks werden als abrechenbar akzeptiert

### Requirement: Proposal-only Bootstrap

Eine Vorschau MUST ausschließlich Inbox-Proposals und einen deterministischen Diff erzeugen. Direkte Jira-, Confluence- oder Dateimutationen sind verboten.

#### Scenario: Read-only Vorschau

- **WHEN** ein Blueprint gegen eine vorhandene Zielrevision verglichen wird
- **THEN** bleiben Zielartefakte byte- und semantisch unveraendert und ein Diff-Proposal entsteht

### Requirement: Fuehrender V2-Vertrag und Legacy-Kompatibilitaet

Neue Blueprint-Vorschauen MUST den maschinenlesbaren V2-Katalog verwenden. Bestehende kuratierte V1-Auswahlen MAY als Herkunft gelesen werden, duerfen aber keine zweite fuehrende Template-Wahrheit oder direkte Mutation erzeugen.

#### Scenario: Alte Init-Auswahl

- **WHEN** eine bestehende Init-Auswahl auf einen kuratierten V1-Eintrag verweist
- **THEN** bleibt die Auswahl lesbar und wird ohne konkurrierende Katalogwahrheit auf den fuehrenden V2-Vertrag abgebildet

### Requirement: Fail-closed Validierung

Unbekannter Blueprint, fehlende Provenienz, Kundenwissen, feste Kardinalitaet, leere Pflichtseite, billable Non-Task, unsichere Referenz und ID-Konflikt MUST mit stabilen Fehlercodes abgelehnt werden.

#### Scenario: Fehlerhafte Vorlage

- **WHEN** eine Vorlage einen unbekannten Blueprint oder eine billable Story enthaelt
- **THEN** wird sie mit dem passenden stabilen Fehlercode abgelehnt

### Requirement: Idempotenz und Connectorgrenze

Gleicher Blueprintstand und gleiche Zielrevision MUST denselben Vorschau-Digest ergeben. Live-Connectoren, Runtime-Secrets und externe Mutationen sind ausserhalb dieses Vertrags.

#### Scenario: Wiederholte Vorschau

- **WHEN** dieselbe Eingabe zweimal dry-run ausgefuehrt wird
- **THEN** sind Vorschau und Digest identisch und es erfolgt kein externer Zugriff
