# Spectra 0.10.0-alpha.1 Candidate-Evidence

## Why

Der veröffentlichte Ausgang `0.9.0-alpha.1` wurde um den generischen Referenzgraph-Projektions- und Coverage-Vertrag sowie den gehärteten Schema-v2-Candidatevertrag erweitert. Beide Produktblöcke sind gemergt und commitgebunden geprüft. Für die unabhängige Releaseentscheidung fehlt nun ausschließlich die reproduzierbare, nicht installierbare Candidate-Evidence.

## What Changes

- Erzeugung des Schema-v2-Candidates `0.10.0-alpha.1` aus dem unveränderlichen Mergecommit und dessen Tree.
- Speicherung der 110 Git-Blob-Payloadrecords, Checksums und des SHA-256-Bundledigests.
- Dokumentation von Scope, Gates und bekannten Grenzen ohne Kundenwerte.
- Commitgebundene Candidate-, Produkt-, Coverage-, Workspace-, Upgrade-, Recovery-, OpenSpec- und Fresh-Clone-Prüfung.

## Nicht-Scope

- keine Promotion oder installierbare Finalbehauptung;
- kein annotierter Tag, Push, PR, Merge oder GitHub-Release;
- keine Produktfunktion außerhalb der bereits gemergten Payload;
- keine Kunden-, Fremdprojekt- oder Live-System-Evidence.
