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

## Übertragene, anonymisierte Lernbefunde

| Finding-ID | Herkunft / Commit | Klassifikation | Evidence / Anonymisierung | Zielentscheidung | Status |
|---|---|---|---|---|---|
| `BCBASIC-CONSUMER-READONLY-001` | BC Basic / vollständiger Commit wird im Consumer-Handoff gebunden | Consumer-seitig | portable read-only Prüfung; keine Kundendaten übernommen | Consumer-Validierung als generische Produktanforderung | proposed |
| `BCBASIC-PLAYTHROUGH-001` | BC Basic / vollständiger Commit wird im Consumer-Handoff gebunden | generisch-produktseitig | Seite, Aktion, Feld, Preview, Dokument, Ledger, Kontrolle, Fehler, Retest als Modell | in den Projektbetriebs-/Playthrough-Kern aufnehmen | proposed |
| `BCBASIC-GATES-FIRSTCLASS-001` | BC Basic / vollständiger Commit wird im Consumer-Handoff gebunden | generisch-produktseitig | simulierte Freigaben als First-Class-Gates; synthetisch und anonymisiert | Kontrollkern um Gate-Records erweitern | proposed |
| `SPECTRA-ID-CONTRACT-001` | Spectra Consumerprüfung / gebundener Commit | Kontroll-/Release-seitig | zentrale Producer-ID-Regel statt abweichender Consumerregex | zentralen ID-Vertrag als einzige Quelle festlegen | proposed |
| `SPECTRA-BRANCH-BINDING-001` | Spectra Consumerprüfung / gebundener Commit | Consumer-/Release-seitig | `allowedBranch`, `validationStatus`, Allowlistpfade | in Consumer-Binding-Schema und Validator planen | proposed |
| `SPECTRA-LEGACY-MANIFEST-001` | Spectra Releaseprüfung / gebundener Commit | Kontroll-/Release-seitig | Legacy-Manifeste dürfen Branch-Consumer nicht ungewollt blockieren | Kompatibilitätsregel mit negativer Regressionsevidence | proposed |
| `TWIN-STATUS-VIEWS-001` | Project Twin / gebundener Commit | Twin-seitig | Status-, Abschluss-, Demo- und Evidence-Sichten | nur bei generischer Portabilitäts-/Validatorlücke übernehmen | proposed |
| `SPECTRA-BACKUP-RESTORE-001` | Spectra Gap-Matrix / `05b0260...` | generisch-produktseitig | Backup/Restore weiterhin fehlend | eigener späterer P1-Block | proposed |

Alle Befunde sind anonymisiert; keine Rohdaten, Kunden-Evidence oder Fremdrepositoryänderungen wurden übernommen.
