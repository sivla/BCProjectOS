## 1. Validator

- [x] 1.1 Implementiere den strikt read-only Workspace-Validator.
- [x] 1.2 Prüfe Pfade, Schema, IDs, Profil, OpenSpec-Root und Katalogintegrität.
- [x] 1.3 Prüfe BOUND-Release, Manifest-Source und SHA-256-Payload-Digest.
- [x] 1.4 Blockiere sensible Muster und unzulässige Workspace-Zustände.

## 2. Evidence

- [x] 2.1 Führe Installation→Validierung synthetisch positiv aus.
- [x] 2.2 Beweise Katalogdrift und Mutationserkennung negativ.
- [x] 2.3 Führe Product-, OpenSpec-, Diff- und Secret-Gates aus.
- [x] 2.4 Gleiche Entity-, Evidence- und External-File-Schemas automatisch gegen Validatorrouten ab.
- [x] 2.5 Erzeuge deterministische Paritäts- und Fehlercode-Evidence für den Releasekandidaten 0.1.0-alpha.2.

## 3. Release-Scope 0.1.0-alpha.2

- [x] 3.1 Scope ist ausschließlich der spezialisierte read-only Workspace-Validator.
- [x] 3.2 MVP-2+-Funktionen bleiben ausdrücklich außerhalb des Kandidaten.
- [x] 3.3 Candidate-Manifest und Digest werden nur lokal als Candidate-Evidence erzeugt.
