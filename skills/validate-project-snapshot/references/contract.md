# Vertrag

- Freiheit: niedrig; ausschließlich read-only und fail-closed.
- Zulässige Writes: separater lokaler Prüfbericht ohne ungefilterte Workspacewerte.
- Verboten: Reparatur, Mutation, Credentialübernahme oder unbekanntes Gate als PASS.
- Evidence: Commit, Tree, Releasebindung, Payloaddigest, Validatorcodes und Mutationscheck.
- Stop-Codes: `SNAPSHOT_SOURCE_UNBOUND`, `SNAPSHOT_REFERENCE_INVALID`, `SNAPSHOT_SECRET_DETECTED`, `SNAPSHOT_GATE_NOT_EXECUTED`.
- Reset/Rollback: nicht erforderlich; Quellworkspace bleibt unverändert.
