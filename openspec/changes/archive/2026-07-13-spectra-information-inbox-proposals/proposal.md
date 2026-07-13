# Proposal: Kontrollierte Informations-Inbox und Änderungsvorschläge

## Ziel

Spectra soll neue Projektinformationen sicher aufnehmen und daraus nachvollziehbare, ausschließlich menschlich entscheidbare Vorschläge erzeugen. Intake bleibt unveränderlich und darf keine Jira-, Confluence-, Budget-, Status- oder Dokumentationsquelle direkt überschreiben.

## Scope

- generischer Intake-Vertrag für Dokumente, Transkripte, Prozessbeschreibungen, Musterdateien, Supportfälle sowie BC-/Repository-Befunde;
- Kunden-, Projekt- und Supportfall-Zuordnung, einschließlich Supportfällen ohne Projekt;
- unveränderliche Quellprovenienz, Klassifikation, Sensitivität, Hash und Intake-Revision;
- Proposal-Vertrag mit Zielobjekt, Änderungsart, Begründung, Konflikten, offenen Fragen, Risiko, Reviewer und getrennten Annahme-/Umsetzungsstatus;
- Audit-Referenzen für später ableitbare Projekttagebücher und snapshotbasierte, read-only Zeitreisen;
- fail-closed Schema-, Generator- und Validatorvertrag mit synthetischen Fixtures in einem späteren Implementierungsschritt.

## Nicht-Scope

- keine UI und keine Jira-/Confluence-/BC-/Repository-Connectoren;
- keine automatische Übernahme, Annahme, Umsetzung oder stille Reparatur;
- keine Kundenwerte, Secrets, Authzustände oder ungefilterten Kundendaten im Produktpayload;
- kein Budget-, Ticket-, Status- oder Dokumentenschreibvorgang;
- keine Releaseversion oder Promotion in diesem Change.

## Nutzen

Consultants können neue Informationen kontrolliert sammeln, Konflikte sichtbar machen und eine belegte Reviewentscheidung vorbereiten, ohne die führenden Kundenquellen zu beschädigen.
