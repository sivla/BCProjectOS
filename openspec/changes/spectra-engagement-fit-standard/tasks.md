## 1. Vertrag und Evidence

- [x] 1.1 0.10-Gap-Matrix gegen die kundennahe Portfolio-Leitlinie aktualisieren (`notes/spectra-1.0-gap-matrix.md`).
- [x] 1.2 Engagement-/Fit-to-Standard-Schema und Wahrheitsgrenzen definieren (`schemas/engagement-fit-standard.schema.json`, `contract/engagement-fit-to-standard.md`).
- [x] 1.3 Proposal, Design, Spec, Scope und Nicht-Scope strict validieren (`openspec validate spectra-engagement-fit-standard --strict`: PASS).

## 2. Produktimplementierung

- [x] 2.1 Deterministischen synthetischen Engagement-/Fit-to-Standard-Generator implementieren (`New-SyntheticEngagementFitStandard.ps1`).
- [x] 2.2 Rekursive Schema- und semantische Readinessvalidierung mit stabilen Codes implementieren (`Test-EngagementFitStandard.ps1`).
- [x] 2.3 Read-only CLI-Route und deutsche Operatoranleitung ergänzen (`Invoke-Spectra.ps1`, `spectra-engagement-fit-standard-operator.md`).
- [x] 2.4 Positive Gesamtfixture sowie 18 isolierte Negativfälle mit echtem Fehleroracle implementieren (`Test-EngagementFitStandardContract.ps1`, `Test-EngagementFitStandardNegative.ps1`).

## 3. Kompatibilität und Abnahme

- [x] 3.1 Product Contract, Engagement-Suite und bestehende Operator-/Workspace-Gates ausführen (PASS).
- [x] 3.2 Upgrade- und Backup/Restore-Kompatibilität nachweisen (`Test-WorkspaceUpgrade.ps1`, `Test-BackupRestore.ps1`: PASS).
- [x] 3.3 OpenSpec strict, Diff-/Secret-/Tenant-/Kundenmarkerscan und Fresh-Product-Clone ausführen (PASS).
- [x] 3.4 Tatsächliches Delta und verbleibende 1.0-Lücken dokumentieren; keine Version vor Evidence behaupten (`notes/spectra-1.0-gap-matrix.md`).
