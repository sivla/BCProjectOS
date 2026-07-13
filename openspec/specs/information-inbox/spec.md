# information-inbox Specification

## Purpose
TBD - created by archiving change spectra-information-inbox-proposals. Update Purpose after archive.
## Requirements
### Requirement: Unveränderlicher Intake

Jedes IntakeItem MUST eine stabile ID, Kunden-/Workspacebezug, Quellprovenienz, Revision, SHA-256, Klassifikation, Sensitivität, Intake-Zeit und aufnehmende Rolle besitzen. Ein Supportfall MAY ohne Projektbezug geführt werden.

#### Scenario: Synthetisches Dokument wird aufgenommen

- WHEN eine synthetische Quelle mit sicherer relativer Referenz, Hash und Workspacebezug aufgenommen wird
- THEN entsteht genau ein unveränderliches IntakeItem und keine Zielquelle wird verändert.

#### Scenario: Fehlende Provenienz

- WHEN Quelle, Revision, Hash oder Klassifikation fehlt
- THEN wird `INBOX_PROVENANCE_REQUIRED` ausgegeben und kein Item als geprüft markiert.

#### Scenario: Rückwirkend veränderte Quelle

- WHEN dieselbe Intake-Revision später einen anderen Hash besitzt
- THEN wird `INBOX_SOURCE_CHANGED` ausgegeben und die neue Verarbeitung fail-closed abgebrochen.

### Requirement: Proposal-only-Verarbeitung

Eine Observation MUST ausschließlich belegte Information referenzieren. Ein Proposal MUST Zielobjekt, Änderungsart, Begründung, Konflikte, offene Fragen, Risiko, Reviewer und Status führen. Intake MUST niemals direkt Jira, Confluence, Budget, Projektstatus oder technische Dokumentation ändern.

#### Scenario: Vorschlag ohne automatische Mutation

- WHEN eine Observation ein bestehendes Ticket oder Dokument betrifft
- THEN wird ein Proposal erzeugt, aber der Zielstand bleibt byte- und semantisch unverändert.

#### Scenario: Unbekanntes Ziel

- WHEN ein Proposal auf eine nicht vorhandene oder nicht erlaubte Zieldomäne zeigt
- THEN wird `INBOX_TARGET_UNKNOWN` ausgegeben und kein Annahmestatus gesetzt.

#### Scenario: Direkte Mutation

- WHEN ein Intake-Lauf versucht, ohne getrennte Annahme-/Umsetzungsentscheidung zu schreiben
- THEN wird `INBOX_DIRECT_MUTATION_FORBIDDEN` ausgegeben.

### Requirement: Getrennte Review- und Umsetzungsentscheidungen

Annahme und Umsetzung MUST getrennte, auditierbare Ereignisse mit Akteur, Rolle, Zeit und Referenz sein. Der Ersteller eines Proposals MUST es nicht allein selbst freigeben.

#### Scenario: Selbstfreigabe

- WHEN Ersteller und alleiniger Reviewer identisch sind
- THEN wird `INBOX_SELF_APPROVAL_FORBIDDEN` ausgegeben.

#### Scenario: Zurückgestellter Vorschlag

- WHEN offene Frage oder Konflikt die Entscheidung verhindert
- THEN bleibt der Proposalstatus `zurückgestellt` und es entsteht keine Umsetzung.

### Requirement: Idempotenz und Audit

Eine gleiche Quellrevision MUST höchstens ein IntakeItem und eine deterministische Observation erzeugen. Auditdaten MUST vorher/nachher, Quelle, Entscheidung und betroffene Referenzen nur nach belegter Quelle enthalten. Zeitreisen MUST aus validierten Snapshots read-only rekonstruiert werden.

#### Scenario: Doppelte Verarbeitung

- WHEN dieselbe Quelle mit identischem Revision- und Hashpaar erneut verarbeitet wird
- THEN wird sie als bereits verarbeitet erkannt und kein zweites Ereignis erzeugt.

#### Scenario: Geheime oder sensible Inhalte

- WHEN ein Intake-Muster Secrets oder unzulässige sensible Rohdaten erkennt
- THEN wird `INBOX_SENSITIVE_CONTENT_BLOCKED` ausgegeben und das Original bleibt außerhalb des Produktpayloads.

#### Scenario: Unsicherer Pfad

- WHEN die Originalreferenz absolut, traversalverdächtig oder ein Reparse-/Symlinkziel ist
- THEN wird `INBOX_PATH_UNSAFE` ausgegeben.
