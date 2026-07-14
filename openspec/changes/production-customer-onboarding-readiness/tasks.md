## 1. Vertrag

- [x] 1.1 Alpha.12-Evidence reconciliert und Vorgängerchange archiviert
- [x] 1.2 Readiness-, Operator- und Distributionsgrenzen definiert
- [x] 1.3 OpenSpec strict validieren

## 2. Implementierung

- [x] 2.1 Schema und fail-closed Validator implementieren
- [x] 2.2 deterministischen Preflight-/Plan-/Validate-Weg implementieren
- [x] 2.3 sanitisiertes Onboardingpaket und deutsche Operatorführung implementieren
- [x] 2.4 commitgebundene Production-Readiness-Evidence implementieren

## 3. Evidence

- [x] 3.1 vier Profile positiv und Negativmatrix belegen
- [x] 3.2 Implementation und Support-only in frischen Kopien belegen (`Test-SpectraV1IntegratedInitPilots.ps1`: PASS; zwei releasegebundene Guided-Init-Profile, 31 Operatoraufrufe und V1-GO-Evidence)
- [x] 3.3 Upgrade, Backup/Restore und Product Contract belegen (`Test-WorkspaceUpgrade.ps1`: PASS; Backup/Restore und Product Contract PASS)
- [x] 3.4 Diff-, Secret-/Kundenmarker-, REVIEW- und sauberen Commit belegen (Commit `abe8a92d5ae9c7c5ae9b0bab01b419853540fc92`; Diff-/Secret-/Kundenmarkerscan PASS; REVIEW leer/nicht vorhanden und Arbeitsbaum zum Commit sauber)
## 4. Stable-Release 1.0.0

- [ ] 4.1 Iststand-/1.0-Gap-Matrix und OpenSpec-Anforderungen festhalten
- [ ] 4.2 Stale 1.0-Kandidaten-Evidence durch einen source-bound Candidate des tatsächlichen Produktstands ersetzen
- [ ] 4.3 Installations-, Upgrade-, Recovery- und fail-closed Negativtests gegen den Stable-Kandidaten ausführen
- [ ] 4.4 Candidate in finalen Manifeststatus promoten, annotierten `spectra-v1.0.0`-Tag erzeugen und Commit/Tree/Digest prüfen
- [ ] 4.5 Kanonischen Remote-Tag und reproduzierbare Veröffentlichung prüfen; bei externem Gate Übergabepaket mit offenem Status übergeben
