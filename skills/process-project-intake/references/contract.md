# Vertrag

- Freiheit: hoch für Analyse, null für Zielmutation.
- Fuehrender Lebenszyklus: `information-inbox.json`; `knowledge-inbox.json` bleibt ausschließlich eine read-only Foundation-/Kompatibilitaetsprojektion und darf keine Umsetzung autorisieren.
- Zulässige Writes: Intake-, Observation-, Comparison- und Proposalrecords im autorisierten Workspace.
- Verboten: direkte Ticket-/Seitenänderung, automatische Annahme, unklassifizierte Dateien.
- Evidence: Source-Hash, Revision, Vergleichsdigest, Referenzen und Reviewstatus.
- Stop-Codes: `INTAKE_CLASSIFICATION_UNKNOWN`, `INTAKE_SOURCE_CHANGED`, `INTAKE_STALE`, `INTAKE_SECRET_DETECTED`.
- Reset/Rollback: Intake append-only korrigieren; Quelle und vorherige Records nie überschreiben.
