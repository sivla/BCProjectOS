## 1. Produktvertrag

- [x] 1.1 Setup-, Rollen-/SoD- und Datenvertrag mit offiziellen BC-Referenzen definieren (`contract/setup-permissions-data.md`)
- [x] 1.2 Schema, Generatoren fuer beide Profile und read-only Validator implementieren (`schemas/setup-permissions-data.schema.json`, `automation/New-SyntheticSetupPermissionsData.ps1`)
- [x] 1.3 Positive Fixture und isolierte Negativmatrix nachweisen (beide Profile und 10 isolierte Fehlerklassen: PASS)
- [x] 1.4 CLI, deutsche Dokumentation und Gap-Matrix aktualisieren (`Invoke-Spectra.ps1`, Quickstart, Gap-Matrix)
- [x] 1.5 Upgrade, Backup/Restore, Regression, OpenSpec strict und Fresh Clone nachweisen (commitgebundene Wegwerfkopie: PASS)
- [x] 1.6 PENDING-Candidate aus belegtem Produktcommit erzeugen und commitgebunden pruefen (`0.12.0-alpha.1`, 124 Payloads, veröffentlichter Postcheck: PASS)
