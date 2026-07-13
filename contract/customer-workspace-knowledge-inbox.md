# Kundenworkspace- und Knowledge-Inbox-Vertrag

## Kunden- und Scopegrenze

Ein Workspace führt genau einen Kunden. Umgebungen, Gesellschaften, Projekte, Supportfälle, Wissen, Budgets und Lieferverpflichtungen besitzen stabile IDs und eine explizite Kunden- oder Scopebindung. Ein Support-only-Kunde ohne Projekt ist gültig; Spectra erzeugt kein künstliches Projekt.

Budgets sind Projektforecast und keine Accounting-Quelle. Lieferverpflichtungen behaupten ohne Kundenentscheidung keine Abnahme. Production-Umgebungen werden höchstens als Referenz geführt; dieser Vertrag führt keine produktive Aktivität aus.

## Personen, Rollen und Akteure

Personen stammen ausschließlich aus dem Kundenworkspace. `display_name` wird niemals aus Git, Betriebssystem, Authentifizierung oder Codex abgeleitet. Eine Person kann mehrere Scope-Rollen besitzen. Jede Entscheidung nennt `acting_role_id`.

Unbesetzte Rollen bleiben `pending` oder `unknown` und enthalten keine erfundene Person. Berechtigungen unterscheiden technische Ausführung, interne Entscheidung, Kunden-UAT/Abnahme, Steuer-/Rechtsbestätigung und Supportannahme. Playwright, Codex/Spectra und Systemakteure dürfen technische Ausführung belegen, aber keine menschliche Annahme oder Ablehnung übernehmen.

## Knowledge Inbox

Wenn beide Inbox-Vertraege vorhanden sind, kennzeichnet `lifecycle_authority: foundation-read-only` die bisherige Knowledge Inbox explizit als nicht fuehrende Kompatibilitaetsprojektion. Nur die Information Inbox fuehrt den aktiven Proposal-Lebenszyklus.

Intake-Dateien bleiben unveränderlich und werden über sicheren relativen Pfad, Quellsystem, Objekt-ID, Revision, Größe und SHA-256 gebunden. Gleiche Quellrevisionen dürfen kein zweites IntakeItem erzeugen.

Observations beschreiben nur belegte oder ausdrücklich unbekannte Sachverhalte. ComparisonRuns binden den aktuellen Workspace-Digest. Proposals enthalten einen erwarteten Digest und bleiben vom kanonischen Workspace getrennt. ReviewDecisions sind menschliche Entscheidungen; auch eine Annahme erzeugt in diesem Block keinen Apply-Plan und keine Zielmutation.

Der Status in `knowledge-inbox.json` ist nur eine read-only Foundation-/Kompatibilitaetsprojektion. Fuer neue Verarbeitung, erneute Pruefung, Annahme und getrennte Umsetzung ist ausschließlich der `information-inbox`-Vertrag fuehrend. Legacy-Status wird nicht automatisch in kanonische Audit-Evidence umgedeutet.

Stale-Vergleiche, offene Konflikte, unbekannte Referenzen, automatische Writes und sensible Marker werden fail-closed abgelehnt.
