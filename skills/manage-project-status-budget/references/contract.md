# Vertrag

- Freiheit: mittel; Berechnung deterministisch, Bewertung fachlich.
- Zulässige Writes: validierte Status-, Forecast-, Risiko- und Decisionrecords nach Review.
- Verboten: Buchung, Rechnungsbehauptung, rückwirkende Worklogerfindung.
- Evidence: Baseline, Rate, Stunden, Betrag, Abweichungsgrund und Quellrevision.
- Stop-Codes: `BUDGET_BASELINE_MISSING`, `WORKLOG_TOTAL_MISMATCH`, `FORECAST_SOURCE_STALE`, `SCOPE_DECISION_REQUIRED`.
- Reset/Rollback: neue Revision append-only; vorherigen Snapshot erhalten.
