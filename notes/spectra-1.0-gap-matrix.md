# Spectra 1.0.0 Gap-Matrix nach 0.12.0-alpha.1

Bewertungsbasis ist der veröffentlichte und gebundene Release `0.12.0-alpha.1`. Statuswerte sind `vorhanden`, `teilweise`, `fehlend` oder `unbewiesen`. Synthetische Evidence ist keine reale Kunden-, BC-, Steuer- oder Rechtsaktivität.

## Produkt- und Betriebsfähigkeit

| Pflichtbereich | Status | Evidence | Verbleibende Hauptlücke |
|---|---|---|---|
| Produktkern/Schemas | teilweise | Engagement, Setup/Daten und UAT/Training/Defects | Cutover/Betriebsübergabe fehlt |
| Implementation-Profil | teilweise | deterministische Fachprofile und Installationsgates | unabhängiger Pilot bis Handover fehlt |
| Support-only-Profil | teilweise | Operator- und Fachprofile | vollständiger Support-/Knowledge-Pilot fehlt |
| Engagement/Fit-to-Standard | vorhanden | Scope, E2E-Prozesse, Fit/Gap und Entscheidungen | reale Kundenparameter bleiben Kundenevidence |
| Setup/Berechtigungen/Daten | vorhanden | 14 Setupbereiche, SoD-Proben, acht Vorlagen und drei Wellen | reale Pilotevidence bleibt unbewiesen |
| UAT/Training/Defects | teilweise | sieben Kernprozesse, vier Testpfade, Rollenbefähigung, Defect-/Exit-Gates | unabhängige Pilotevidence bleibt unbewiesen |
| Validatorplattform | vorhanden | Schema, referenzielle Regeln, stabile Fehlercodes und Negativmatrizen | neue Fachtypen je Release integrieren |
| Upgrade | vorhanden | Dry-run, Konflikte, Apply, Wiederholung und Kundeninhaltschutz | RC-Kompatibilitätsmatrix fehlt |
| Backup/Restore | vorhanden | Profil-Roundtrips und Recoverygates | großer unabhängiger Recoverypilot fehlt |
| CLI/Bedienung | vorhanden | Fachgeneratoren/-validatoren, Upgrade und Recovery | End-to-End-Handbuch bis RC konsolidieren |
| Supply Chain | vorhanden | Candidate-/Finalprovenienz, Tag, Payload und Digest | RC-/1.0-Gesamtproof fehlt |

## Aktiver Releaseblock

`spectra-uat-training-defects` führt von der Testvorbereitung über rollenbezogene Befähigung und Defect-Retest bis zur Exit-Entscheidung. Das additive Delta begründet `0.13.0-alpha.1`. Cutover, Hypercare, Restart, Supportbetrieb und Handover sind ausdrücklich Nicht-Scope.

## Priorisierte Folgeblöcke bis 1.0

1. Cutover und Betriebsübergabe: Mock-Cutover, Go-live, Hypercare, Restart, Support und Handover.
2. RC-Pilot: unabhängige Implementation- und Support-only-Piloten, Upgrade, Backup/Restore, Recovery und deutsche Handbücher ohne offene P1/P2.
3. `1.0.0`: erst nach unabhängiger Evidence für alle Pflichtfähigkeiten.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth oder Kunden-Evidence wird in Spectra übernommen.
- Sandbox, Profile und technische Automation sind keine Produktions-, Berechtigungs- oder fachliche Freigabeevidence.
- P1–P4, Waiver, Retest und Exit-Gates sind Spectra-Governance.
- Releaseversionen entstehen nur aus belegtem Delta und getrenntem Release-Gate.
