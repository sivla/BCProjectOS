## 1. Vertrag

- [x] 1.1 Coverage-, Nenner-, Outcome- und Reason-Code-Semantik spezifizieren.
- [x] 1.2 Geschlossenes Schema und deutsche Produktgrenze dokumentieren.

## 2. Produkt

- [x] 2.1 Deterministischen synthetischen Generator und kanonisches Beispiel implementieren.
- [x] 2.2 Read-only Validator für Schema, Pfade, Digests, Klassen, Summen und Claims implementieren.
- [x] 2.3 CLI- und portable Full-Conformance-Einbindung ergänzen.

## 3. Evidence

- [x] 3.1 Positive Fixture und acht isolierte Negativfälle mit Exact-Code-Oracle nachweisen (`Test-ReferenceGraphCoverageContract.ps1`, `Test-ReferenceGraphCoverageNegative.ps1`).
- [x] 3.2 Product Contract, OpenSpec strict, Diff-/Marker-Scan und Fresh-Clone-Prüfung ausführen (commitgebundene Übergabeevidence).
- [x] 3.3 Payloadauswirkung 102 → 109 und begründeten Candidate-Vorschlag `0.10.0-alpha.1` aus dem belegten additiven Delta ableiten (`design.md`).
