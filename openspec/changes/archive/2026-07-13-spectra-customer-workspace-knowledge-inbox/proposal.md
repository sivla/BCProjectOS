# Change: Kundenworkspace- und Knowledge-Inbox-Fundament

## Why

Spectra kann Projekte initialisieren und fachliche Projektarten unterscheiden. Für den dauerhaften Betrieb fehlt noch ein kundenbezogener Kern, der Umgebungen, Gesellschaften, optionale Projekte, direkte Supportfälle, Wissen, Budgets und Lieferverpflichtungen gemeinsam führt. Neue Quellen dürfen diesen Stand nicht automatisch verändern, sondern müssen nachvollziehbare Beobachtungen und Vorschläge erzeugen.

## What Changes

- Kundenworkspace-Vertrag für genau einen Kunden mit Umgebungen, Gesellschaften, null bis vielen Projekten, Supportfällen, Wissen, Budgets und Lieferverpflichtungen.
- Stabile Scope-Relationen und gültiger Supportbetrieb ohne künstliches Projekt.
- Knowledge Inbox mit IntakeItem, Observation, MeetingPackage, ComparisonRun, Proposal, ReviewDecision, Konflikten und Stale-Erkennung.
- Unveränderlicher lokaler Datei-Intake mit Hash-/Revisionsbindung und idempotenter Deduplizierung.
- Proposal-only-Verhalten: keine Änderung des kanonischen Workspace ohne späteren kontrollierten Plan.
- Deterministische Implementation- und Support-only-Fixtures, Validatoren, CLI-Routen und isolierte Negativmatrix.

## Nicht-Scope

- Keine Live-Jira-/Confluence-Verbindung und keine Atlassian-Materialisierung.
- Kein Repository-/Extensioninventar, Skillkatalog oder Projektjournal.
- Keine automatische Ausführung akzeptierter Vorschläge.
- Keine Kundenwerte, Credentials oder reale Evidence.
- Keine Version, Candidate- oder Releasebehauptung.
