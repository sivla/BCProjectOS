# Spectra 1.0.0 Gap-Matrix nach Beta-1

Bewertung aus dem tatsächlichen Branch `codex/spectra-bc-basic-simulation` und den vorhandenen lokalen Gates. Kein Kunden- oder Live-BC-Nachweis wird behauptet.

| Pflichtbereich | Status | Evidence | Größte Lücke |
|---|---|---|---|
| Produktkern/Schemas | teilweise | `schemas/*.schema.json`, `Test-ProductContract.ps1` | Viele katalogisierte Fachdaten-Typen fehlen noch als spezialisierte Schemas |
| Implementation-Profil | teilweise | `New-CustomerWorkspace.ps1`, Workspace-Gates | Kein vollständiger Projektbetrieb mit allen Artefakten |
| Support-only-Profil | fehlend | Kein eigener positiver End-to-End-Test | Profilpfad und Profilwechsel unbewiesen |
| Workspace-Init | vorhanden | Generator- und Installationssuite | Vollständige optionale Module/Dry-run-Ausgabe fehlen |
| Projektbetrieb | teilweise | synthetische BC-Basic-Fixture | Keine kanonischen Phasen, Work Packages, Risiken, Entscheidungen und Termine als Modell |
| BC-Basic-Prozesskette | teilweise | `New-/Test-SyntheticBCBasicFixture.ps1` | Nur synthetische Gate-Matrix, keine vollständigen fachlichen Datensätze |
| Tickets/Changes/Wissen | fehlend | Keine produktive Schema-/Generatorroute | Einheitlicher Ticket- und Wissensvertrag fehlt |
| Evidence/Datei-Intake | teilweise | Evidence-/External-File-Validator | Kein kontrollierter Inbox-/Quarantäne-/Dry-run-Intake |
| Validator | teilweise | Workspace- und Schema-Paritätsvalidator | Keine vollständige Referenzgraph-, Zyklus-, Duplikat- und Verwaistenprüfung |
| Upgrade/Migration | vorhanden | `Plan-WorkspaceUpgrade.ps1`, synthetische Upgrade-Suite | Kompatibilitätsmatrix und Deprecation-Policy fehlen |
| Backup/Restore | fehlend | Keine produktiven Backup-/Restore-Befehle | Integritätsmanifest und Roundtrip-Proof fehlen |
| Sicherheit/Datenschutz | teilweise | Secret-/Tenant-Scans, Pfad-/Alias-Gates | Klassifikation, Retention, Export und Löschung fehlen als ausführbare Regeln |
| CLI/Bedienung | teilweise | PowerShell-Skripte vorhanden | Einheitliche Hilfe, Exitcodes und JSON-Ausgabe fehlen |
| Dokumentation | teilweise | Operator-/Release-Notizen | Quickstarts für Implementation/Support-only fehlen |
| Supply Chain | vorhanden | Candidate-/Promotion-/Tag-/Digest-Gates | SBOM/Werkzeugtransparenz und frischer Clone für jeden Folgeschritt ausbauen |

## Abgeleiteter nächster großer Block

Der größte zusammenhängende P1/P2-Abstand ist ein **vollständiger Workspace-Betriebs- und Kontrollkern**: beide Profile, kanonische Projekt-/Ticket-/Risiko-/Entscheidungs-/Work-Package-Datensätze, Referenzgraphvalidierung, einheitliche JSON-Diagnosen und ein synthetischer Implementation-vs-Support-only-End-to-End-Lauf. Eine Folgesemver wird erst nach diesem Delta und seiner Evidence festgelegt.
