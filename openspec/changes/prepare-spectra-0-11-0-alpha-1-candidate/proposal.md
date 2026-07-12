# Change: Spectra 0.11.0-alpha.1 als PENDING-Candidate vorbereiten

## Why
Der bereits belegte, additive Engagement-/Fit-to-Standard-Durchstich und der notwendige Provenienzfix sollen als getrennte, nicht installierbare Candidate-Evidence pruefbar werden.

## What Changes
- Candidate-Evidence fuer exakt `0.11.0-alpha.1` aus der unveraenderten Produktquelle `e83a6c9febf0ecd17d4aaa109f209bf9ef9d26a9` erzeugen.
- Schema 3 mit `candidate_source_commit/tree`; finale `source_commit/tree` bleiben null.
- Scope, Nicht-Scope, SemVer und bekannte Grenzen ehrlich dokumentieren.

## Nicht-Scope
- Keine neue Produktfunktion, Promotion, Installation, Tag- oder Releasebehauptung.
- Kein Setup-, Datenmigration-, UAT-, Training- oder Cutover-Ausbau.
