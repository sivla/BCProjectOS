# Vertrag

- Freiheit: hoch für Recherche, null für fachliche Mutation.
- Zulässige Writes: ausschließlich ein lokaler, quellgebundener Research-Candidate nach Review.
- Primaerquelle: ueber `reference_snapshot` gebundener und validierter lokaler BC-Reference-Library-Snapshot; Pack-ID und Objektkeys muessen exakt gegen diesen Snapshot aufloesen; Inline-Source-Locks oder floating Branches sind unzulaessig.
- Livequelle: ausschließlich Microsoft Learn, MicrosoftDocs oder BCApps bei Aktualitätsbedarf.
- Evidence: BC-/Appversion, Country, Snapshotdigest, Commit und Quellpfad/URL.
- Stop-Codes: `KNOWLEDGE_LOCK_MISSING`, `KNOWLEDGE_VERSION_MISMATCH`, `KNOWLEDGE_SOURCE_UNOFFICIAL`, `KNOWLEDGE_PURPOSE_UNKNOWN`.
- Reset/Rollback: keine Writes; neue Erkenntnis als kuratierten Candidate vorschlagen.
