# Dokumenttypen, Tags, Lifecycle und Freigabe

Status: Accepted for MVP 0

Kontrollierte Werte stehen in `catalogs/`. Dokumenttyp beschreibt die Inhaltsart; Tags klassifizieren; Relationen verbinden; Status beschreibt Zustand. IDs und externe Schluessel sind keine Tags.

## Statusachsen

- Lifecycle: `draft -> active -> inactive -> archived`; `deleted` nur nach kontrolliertem Loeschprozess.
- Review: `unreviewed -> in_review -> accepted | rejected | needs_clarification`.
- Fachliche Freigabe: `draft -> proposed -> approved | rejected`; freigegebener Inhalt kann `superseded` werden.
- Arbeit: `new -> triage -> planned -> in_progress -> validation -> done`, mit `waiting` und `blocked` als kontrollierten Zwischenzustaenden.
- Intake: `received -> review -> accepted | duplicate | rejected`, mit `quarantine` fuer technische oder Sicherheitsprobleme.
- Change: `draft -> planning -> build_ready -> in_progress -> validation -> release_ready -> released -> archived`, wobei Readiness berechnet und fail-closed ist.

`approved`, `passed`, `delivered`, `released` und gleichwertige Behauptungen erfordern mindestens eine gueltige `EVD-*`-Referenz. Dateiexistenz und generierter Inhalt sind kein Nachweis. Automatisierung und KI duerfen eine Freigabe nicht selbst erteilen.

Unbekannte Dokumenttypen oder Sensitivitaeten werden akzeptiert als `unknown`, aber technisch wie `restricted` behandelt und nach `review` geroutet. Ohne Review duerfen daraus weder Wissen noch Tickets, Requirements oder Evidence automatisch bestaetigt werden.
