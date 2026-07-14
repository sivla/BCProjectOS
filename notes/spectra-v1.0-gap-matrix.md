# Spectra 1.0.0 – Gap-Matrix

Stand: 2026-07-14  
Produkt: `spectra`  
Repository: BCProjectOS  
Releaseziel: `spectra-v1.0.0`

Diese Matrix ist der Preflight-Ausgang für den 1.0-Change. Sie behauptet keinen Release. Der verbindliche Status bleibt `PENDING_BCPROJECTOS_RELEASE`, bis Manifest, Commit, Tree, annotierter Tag und Digest reproduzierbar zusammenpassen.

| Bereich | Istzustand | 1.0-Akzeptanz | Lücke / Maßnahme | Nachweis |
|---|---|---|---|---|
| Produktidentität | `spectra` ist in Vertrag, Schemas und Release-Skripten verankert | Kundenunabhängige Produktidentität ohne Kundendaten | Bestand prüfen und im finalen Manifest binden | Product Contract, Manifest |
| Datenvertrag | Schemas, Kataloge, Relationen, Status, Tickets und Wissensobjekte vorhanden | Versionierter, reproduzierbarer Kernvertrag | Vollständigkeits- und Negativmatrix gegen den tatsächlich gebundenen Payload ausführen | `Test-ProductContract.ps1`, Schema-Tests |
| Snapshot | Portable-Snapshot-Schema und Consumer-Bindung vorhanden | Snapshot muss an Produktrelease und Integritätsnachweis gebunden sein | Releasegebundene Snapshot-/Consumer-Prüfung als 1.0-Gate verifizieren | Snapshot-/Consumer-Tests |
| Generatoren | Synthetische Workspace-, Init-, Upgrade- und Projektionserzeuger vorhanden | Keine echte Kunden- oder Live-Systemmutation; idempotente Ausgabe | Fresh-Clone- und Idempotenztests für Stable-Manifest ausführen | Install-/Upgrade-Gates |
| Validatoren | Positive/negative Validatoren und Release-Binding-Prüfer vorhanden | Fehlender/falscher Tag, Commit, Tree, Manifest oder Digest muss fail-closed ablehnen | Stable-1.0-Fall und mutierte Negativfälle ausführen | `Test-ReleaseCandidate.ps1 -RequirePublished` |
| Installation | Alpha-gebundener Installationspfad dokumentiert und synthetisch prüfbar | `spectra-v1.0.0` muss als installierbarer Blueprint akzeptiert werden | Finales Manifest nach Payload-Commit erzeugen und Installationsgate wiederholen | `Test-InstallableWorkspaceGates.ps1` |
| Upgrade/Migration | Upgradeplan, Backup/Restore und Kompatibilitätsverträge vorhanden | Idempotentes Upgrade, inkompatible Versionen und Fehler-Recovery sind belegbar | Stable-Version in Upgrade-/Recovery-Matrix einsetzen | Workspace-Upgrade-/Recovery-Tests |
| Betrieb/Sicherheit | Deutsche Operator-Dokumentation und Grenzen vorhanden | Fehler, Recovery, Secrets, Kundenisolation und Live-Apply-Grenzen dokumentiert | 1.0-Runbook auf finalen Releaseverweis aktualisieren, ohne Kunden-Evidence | Runbook, Security-Scan |
| OpenSpec | Ein bestehender Change `production-customer-onboarding-readiness` ist aktiv und fachlich abgehakt | 1.0-Änderung muss proposal/design/spec/tasks-konsistent sein | 1.0-Change mit maximal zulässiger aktiver Change-Zahl führen; abgeschlossene Vorarbeit danach archivieren | Strict-Validation |
| Release-Evidence | `release/versions/1.0.0` ist Kandidat; `source_commit/source_tree` leer; kein `spectra-v1.0.0` | Finales Manifest, Payload-Digest, vollständiger Commit/Tree und annotierter unveränderlicher Tag | Candidate aus gebundenem Source erzeugen, kohärent committen, promoten, lokal verifizieren; Push/Remote-Veröffentlichung nur im erlaubten Übergabeschritt | Manifest, Checksums, Git, Release-Validator |
| Veröffentlichung | Remote enthält Alpha-/RC-Tags, aber kein Stable-1.0-Tag | Kanonischer Remote und Stable-Tag müssen auf denselben belegten Release zeigen | Nach lokalem Beweis gezielt veröffentlichen oder bei fehlender externer Freigabe mit Übergabepaket stoppen | `git ls-remote`, Release-URL |

## Ausgangsgates

- Repository-Root: `C:\Users\kkali\Documents\BC Project OS`
- Branch: `codex/spectra-portable-bootstrap-registry`
- HEAD: `717cf27697b4ea04fbc50f653da84762fd5ef050`
- HEAD-Tree: `c6a6fc5dab606b6d870af2053e355c2efed9762f`
- Arbeitsbaum: sauber beim Preflight
- Remote: `https://github.com/sivla/BCProjectOS.git`
- Lokaler/kanonischer Stable-Tag: nicht vorhanden
- `release/versions/1.0.0/release-manifest.json`: Kandidat, nicht installierbar
- Release-Status: `PENDING_BCPROJECTOS_RELEASE`

## Nicht als bestanden werten

Ein freier SemVer, ein vorhandenes Kandidatenverzeichnis, ein erwarteter Tag, ein alter Alpha-Release oder ein lokaler Arbeitsstand ersetzt keinen finalen Commit-/Tree-/Manifest-/Digest-/Tag-Nachweis.
