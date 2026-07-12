## 1. Source und Scope

- [x] 1.1 Mergecommit, Tree, SemVer und 110-Dateien-Payload als unveränderlichen Candidate-Scope festhalten.
- [x] 1.2 Promotion, Tag, Release und Produktänderungen ausdrücklich ausschließen.

## 2. Candidate-Evidence

- [x] 2.1 Schema-v2-Manifest und Checksums mit dem projektlokalen Generator erzeugen (`release/versions/0.10.0-alpha.1`).
- [x] 2.2 Release Notes und Known Limits ohne Kundenwerte dokumentieren (`release-notes.md`).
- [x] 2.3 Candidate-Validator, Installationsblockade und acht negative Releasevertragsfälle ausführen.

## 3. Gesamtprüfung

- [x] 3.1 Product Contract, Coverage, Workspace, Upgrade und Backup/Restore prüfen (Übergabeevidence).
- [x] 3.2 OpenSpec strict, Diff-/Secret-/Tenant-Scan und Fresh-Product-Clone prüfen (Übergabeevidence).
- [x] 3.3 Genau einen lokalen Candidate-Commit ohne Push, Tag oder Release übergeben.
