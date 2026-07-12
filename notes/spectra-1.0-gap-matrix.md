# Spectra 1.0.0 Gap-Matrix nach 0.11.0-alpha.1

Bewertungsbasis ist der veröffentlichte und gebundene Release `0.11.0-alpha.1`. Statuswerte sind `vorhanden`, `teilweise`, `fehlend` oder `unbewiesen`. Synthetische Evidence ist keine reale Kunden-, BC-, Steuer- oder Rechtsaktivität.

## Produkt- und Betriebsfähigkeit

| Pflichtbereich | Status | Evidence | Verbleibende Hauptlücke |
|---|---|---|---|
| Produktkern/Schemas | teilweise | kanonische Schemas, Product Contract | UAT/Training und Betriebsübergabe fehlen |
| Implementation-Profil | teilweise | Installation, Engagement sowie Setup-/Datenprofil | vollständiger Pilot bis Handover fehlt |
| Support-only-Profil | teilweise | Operatorpilot sowie Setup-/Datenprofil | vollständiger Support-/Knowledge-Pilot fehlt |
| Workspace-Init | vorhanden | sichere Installation und Pfadgates | optionale Fachmodule bleiben Folgeumfang |
| Engagement/Fit-to-Standard | vorhanden | Scope-, Prozess-, Fit/Gap-, Entscheidungs- und Deliverable-Vertrag | reale Kundenparameter bleiben Kundenevidence |
| Setup/Berechtigungen/Daten | teilweise | 14 Setupbereiche, SoD-Proben, acht Vorlagen, drei Wellen | reale Pilotevidence und produktive Ladeadapter sind unbewiesen |
| Validatorplattform | vorhanden | Schema-Parität, stabile Fehlercodes und Negativmatrizen | neue Fachtypen je Release integrieren |
| Upgrade | vorhanden | Dry-run, Konflikte, Apply, Wiederholung und Abbruch | fachliche Migrationsmatrix bis 1.0 vervollständigen |
| Backup/Restore | vorhanden | beide Profile und Roundtrip | großer Recoverypilot bleibt unbewiesen |
| Sicherheit/Kundenisolation | teilweise | Pfad-, Marker-, Intake- und Releasegates | vollständige Threat-/Retention-Matrix fehlt |
| CLI/Bedienung | vorhanden | Init, Validate, Setup/Daten, Upgrade, Backup/Restore | deutsche End-to-End-Hilfe bis RC konsolidieren |
| Supply Chain | vorhanden | Candidate-/Finalprovenienz, Tag, Payload und Digest | RC-/1.0-Gesamtproof fehlt |

## Aktiver Releaseblock

`spectra-setup-permissions-data` verbindet den belegten Engagement-Scope mit geordnetem Setup, generischen Rollen-/SoD-Proben und kontrollierten Datenwellen. Das additive, rückwärtskompatible Delta begründet `0.12.0-alpha.1`. UAT/Training/Defects und Cutover/Betrieb sind ausdrücklich Nicht-Scope.

## Priorisierte Folgeblöcke bis 1.0

1. UAT, Training und Defects: Strategie, Zyklen, Traceability, Korrektur, Retest, Zielgruppen und Befähigung.
2. Cutover und Betriebsübergabe: Mock-Cutover, Go-live, Hypercare, Restart, Support und Handover.
3. RC-Pilot: unabhängige Implementation- und Support-only-Piloten, Upgrade, Backup/Restore, Recovery und deutsche Handbücher ohne offene P1/P2.
4. `1.0.0`: erst nach unabhängiger Evidence für alle Pflichtfähigkeiten.

## Wahrheitsgrenzen

- Keine Kunden-Source-of-Truth oder Kunden-Evidence wird in Spectra übernommen.
- Offizielle BC-Quellen, Kundenentscheidungen und steuerliche/rechtliche Bewertungen bleiben unterscheidbar.
- Generische Permission-Needs sind keine produktiven Permission-Set-Namen.
- Schema-PASS ist kein fachlicher Freigabenachweis.
- Releaseversionen entstehen nur aus belegtem Delta und getrenntem Release-Gate.
