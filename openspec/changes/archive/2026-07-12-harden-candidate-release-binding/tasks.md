## 1. Vertrag

- [x] 1.1 Schema-v2-Zustände, Commit-/Tree-Bindung und Zirkularitätsgrenze spezifizieren.
- [x] 1.2 Legacy-Kompatibilität auf veröffentlichte Schema-v1-Finalmanifeste begrenzen.

## 2. Produkt

- [x] 2.1 Candidate-Generator auf expliziten Quellcommit, Tree und nicht installierbaren Zustand härten (`New-ReleaseCandidate.ps1`).
- [x] 2.2 Candidate-Validator auf Source-/Tree-/Payload-/Digest-/Selbstbezugsprüfung härten (`Test-ReleaseCandidate.ps1`).
- [x] 2.3 Promotion auf ausschließlich gebundene Schema-v2-Candidates umstellen (`Promote-ReleaseCandidate.ps1`).

## 3. Evidence

- [x] 3.1 Positive Bindung, acht negative Fälle und Schema-v1-Finalkompatibilität nachweisen (`Test-CandidateReleaseBinding.ps1`).
- [x] 3.2 Promotion, Product Contract, Workspace, Upgrade, Backup/Restore und OpenSpec strict ausführen (Übergabeevidence).
- [x] 3.3 Commitgebundenen Fresh-Product-Clone und Payloaddelta 109 → 110 nachweisen (Übergabeevidence).
