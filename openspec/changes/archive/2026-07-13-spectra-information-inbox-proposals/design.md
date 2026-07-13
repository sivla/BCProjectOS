# Design: Intake, Proposal und Audit

Ein `IntakeItem` besitzt eine stabile ID, Workspace-/Kundenbezug, optionalen Projekt- oder Supportfallbezug, Quelle, relative Originalreferenz, Medienklassifikation, Sensitivität, Größe, SHA-256, Intake-Zeit, aufnehmende Rolle und unveränderliche Revision. Ein Supportfall darf ohne Projektbezug gültig sein. Absolute Laufzeitpfade und Geheimnisse sind niemals Vertragswerte.

Eine `Observation` beschreibt nur belegte erkannte Information. Ein `Proposal` referenziert Intake und Observation, benennt Zielobjektdomäne und Ziel-ID oder einen expliziten neuen Kandidaten, Änderungsart, Begründung, Konflikte, offene Fragen, Risiko, Reviewer und Status. Die Statusfolge trennt `neu`, `geprüft`, `angenommen`, `abgelehnt`, `zurückgestellt` und `umgesetzt`; Annahme und Umsetzung sind nie derselbe Schritt. Der Ersteller darf nicht zugleich alleiniger Reviewer oder Annahmeentscheider sein.

Ein Audit-Ereignis hält Akteur, Zeitpunkt, vorher/nachher nur soweit belegt, Quellrevision, Entscheidung und betroffene Referenzen. Intake und Proposal sind append-only; doppelte Verarbeitung derselben Quellrevision wird idempotent erkannt. Snapshot-Checkpoints und Vergleiche sind read-only. Fehlt eine Quelle oder wurde sie rückwirkend verändert, wird der Vorschlag blockiert und nicht repariert.

Die erste Implementierung bleibt dateibasiert und offline. Generatoren erzeugen ausschließlich synthetische positive und negative Fixtures. Ein späterer Executor darf nur nach expliziter Reviewentscheidung und separatem Changevertrag schreiben.
