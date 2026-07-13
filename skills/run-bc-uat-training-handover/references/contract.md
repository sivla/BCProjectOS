# Vertrag

- Freiheit: mittel; menschliche Gateentscheidungen bleiben extern.
- Zulässige Writes: UAT-, Training-, Defect-, Cutover- und Handoverrecords nach Quellbindung.
- Verboten: simulierte reale Kundenabnahme, automatisches GO, Schließen offener P1/P2.
- Evidence: Testfall, Rolle, Ergebnis, Defect, Fix, Retest, Kompetenz und Abschlusskommentar.
- Stop-Codes: `UAT_ENTRY_NOT_MET`, `UAT_OPEN_HIGH_PRIORITY`, `TRAINING_COMPETENCE_MISSING`, `HANDOVER_APPROVAL_MISSING`.
- Reset/Rollback: falsche Ergebnisse append-only korrigieren; Gatezustand neu berechnen.
