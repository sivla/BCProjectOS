## 1. Umsetzung

- [x] 1.1 Schema und normativen Vertrag auf getrennte Kandidaten-/Finalprovenienz aktualisieren (`schemas/release-manifest.schema.json`, `contract/blueprint-versioning.md`)
- [x] 1.2 Generator, Validator und Promotion fail-closed aktualisieren (`automation/New-ReleaseCandidate.ps1`, `automation/Test-ReleaseCandidate.ps1`, `automation/Promote-ReleaseCandidate.ps1`)
- [x] 1.3 Positive und negative Bindungs-/Promotions-/Kompatibilitaetstests nachweisen (`automation/Test-CandidateReleaseBinding.ps1`, `automation/Test-PromotionWorkflow.ps1`: PASS)
- [x] 1.4 Product Contract, OpenSpec strict und Fresh-Clone-Proof nachweisen (commitgebundene Wegwerfkopie: PASS)
