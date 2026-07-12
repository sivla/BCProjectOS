# Gebundener, nicht installierbarer Candidatevertrag

## Why

Der bisherige Candidatezustand ist ungebunden (`source_commit: null`) und behauptet zugleich `installable_blueprint: true`. Damit kann ein Candidate zwar seinen aktuellen Arbeitsbaum prüfen, aber weder einen unveränderlichen Quellcommit samt Tree belegen noch seine Nichtinstallierbarkeit maschinenlesbar erzwingen. Das widerspricht der fail-closed Trennung zwischen Candidate, Promotion und Veröffentlichung.

## What Changes

- Manifest-Schema v2 bindet Candidates an einen expliziten vollständigen `source_commit` und dessen `source_tree`.
- `manifest_state: candidate` erzwingt `installable_blueprint: false` und `consumer_mode: CONTRACT_REFERENCE_ONLY`.
- Checksums und Digest werden ausschließlich aus den Git-Blobs des gebundenen Quellcommits berechnet; `release/versions` bleibt außerhalb des Payloads.
- Generator, Validator und Promotion lehnen ungebundene, installierbare, manipulierte oder zirkulär selbstreferenzierende Candidates ab.
- Schema-v1 bleibt nur für bereits veröffentlichte Finalmanifeste kompatibel; Legacy-Candidates werden nicht migriert oder akzeptiert.

## Nicht-Scope

- keine konkrete Releaseversion oder Candidate-Datei;
- kein Tag, Push, GitHub-Release oder installierbarer Kundenworkspace;
- keine Änderung fachlicher Spectra-Funktionen oder Kundeninhalte.
