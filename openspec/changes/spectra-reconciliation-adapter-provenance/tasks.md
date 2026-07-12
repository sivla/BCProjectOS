## 1. Contract

- [x] 1.1 Define closed schemas for reconciliation and adapter provenance (`schemas/project-reconciliation.schema.json`, `schemas/adapter-provenance.schema.json`).
- [x] 1.2 Document additive 0.8 compatibility and truth/write boundaries (`contract/project-truth-and-adapter-provenance.md`, `design.md`).

## 2. Product

- [x] 2.1 Implement deterministic read-only reconciliation validation (`automation/Test-ProjectReconciliation.ps1`).
- [x] 2.2 Implement path-safe, byte-hash-bound adapter provenance validation (`automation/Test-AdapterProvenance.ps1`).
- [x] 2.3 Expose both validators through read-only Spectra CLI commands (`automation/Invoke-Spectra.ps1`).
- [x] 2.4 Generate isolated synthetic implementation and support-only profiles (`automation/New-SyntheticSpectra09Profile.ps1`).

## 3. Evidence

- [x] 3.1 Add positive profile and 23 deterministic negative contract cases with exact-code oracle (`automation/Test-Spectra09Contracts*.ps1`).
- [x] 3.2 Prove upgrade and backup/restore compatibility without overwriting customer-owned files (`automation/Test-Spectra09Compatibility.ps1`, `automation/Test-WorkspaceUpgrade.ps1`).
- [x] 3.3 Run Product Contract, OpenSpec strict, diff/secret/customer-marker gates and fresh-clone proof.
- [x] 3.4 Deliver one local function commit without Candidate, manifest, tag or release.
