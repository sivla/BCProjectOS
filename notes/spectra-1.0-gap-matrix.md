# Spectra 1.0.0 Gap-Matrix nach 0.14.0-alpha.1

Bewertungsbasis ist der veröffentlichte und gebundene Release `0.14.0-alpha.1`. Statuswerte sind `vorhanden`, `teilweise`, `fehlend` oder `unbewiesen`. Synthetische Evidence ist keine reale Kunden-, BC-, Steuer- oder Rechtsaktivität.

## Produkt- und Betriebsfähigkeit

| Pflichtbereich | Status | Evidence | Verbleibende Hauptlücke |
|---|---|---|---|
| Produktkern/Schemas | teilweise | Engagement, Setup/Daten, UAT/Training/Defects und lokaler Betriebsdurchstich | unabhängige Pilotevidence fehlt |
| Implementation-Profil | teilweise | deterministische Fachprofile und Installationsgates | unabhängiger Pilot bis Handover fehlt |
| Support-only-Profil | teilweise | Operator- und Fachprofile | vollständiger Support-/Knowledge-Pilot fehlt |
| Engagement/Fit-to-Standard | vorhanden | Scope, E2E-Prozesse, Fit/Gap und Entscheidungen | reale Kundenparameter bleiben Kundenevidence |
| Setup/Berechtigungen/Daten | vorhanden | 14 Setupbereiche, SoD-Proben, acht Vorlagen und drei Wellen | reale Pilotevidence bleibt unbewiesen |
| UAT/Training/Defects | vorhanden | sieben Kernprozesse, vier Testpfade, Rollenbefähigung, Defect-/Exit-Gates | unabhängige Pilotevidence bleibt unbewiesen |
| Cutover/Betriebsübergabe | vorhanden | veröffentlichter Vertrag für Mock-Cutover, Go/No-Go, Hypercare, Restart, Support und Handover | unabhängiger Pilot fehlt |
| Validatorplattform | vorhanden | Schema, referenzielle Regeln, stabile Fehlercodes und Negativmatrizen | neue Fachtypen je Release integrieren |
| Upgrade | vorhanden | Dry-run, Konflikte, Apply, Wiederholung und Kundeninhaltschutz | RC-Kompatibilitätsmatrix fehlt |
| Backup/Restore | vorhanden | Profil-Roundtrips und Recoverygates | großer unabhängiger Recoverypilot fehlt |
| CLI/Bedienung | vorhanden | Fachgeneratoren/-validatoren, Upgrade und Recovery | End-to-End-Handbuch bis RC konsolidieren |
| Supply Chain | vorhanden | Candidate-/Finalprovenienz, Tag, Payload und Digest | RC-/1.0-Gesamtproof fehlt |

## Aktiver Releaseblock

`spectra-v1-pilot-rc-evidence` prüft als einziger aktiver Folgeblock zwei unabhängige Profile, Upgrade, Recovery, Dokumentation und die RC-Reife. Eine RC-Version entsteht erst aus der belegten Evidence; RC- und 1.0-Reife werden noch nicht behauptet.

## Priorisierte Folgeblöcke bis 1.0

1. RC-Pilot: unabhängige Implementation- und Support-only-Piloten, Upgrade, Backup/Restore, Recovery und deutsche Handbücher ohne offene P1/P2.
2. RC-Candidate nur bei vollständigem Funktionsumfang und ehrlichem GO.
3. `1.0.0`: erst nach unabhängiger Evidence für alle Pflichtfähigkeiten.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth oder Kunden-Evidence wird in Spectra übernommen.
- Sandbox, Profile und technische Automation sind keine Produktions-, Berechtigungs- oder fachliche Freigabeevidence.
- P1–P4, Waiver, Retest und Exit-Gates sind Spectra-Governance.
- Releaseversionen entstehen nur aus belegtem Delta und getrenntem Release-Gate.
