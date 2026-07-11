# Spectra 0.1.0-alpha.2 – Releaseplanung

## Scope

Der Kandidat umfasst ausschließlich den produktiven read-only Workspace-Validator: Workspace-/Entity-Vertrag, Customer-Boundary, Status und Relationen, Evidence einschließlich UAT-/Delivery-Untertypen, External-File-Metadaten, SHA-256-Hashes, Content-Addressed-Pfade, stabile Fehlercodes, Paritätsprüfung und synthetische positive/negative Fixtures.

## Nicht-Scope

Keine Datei-Inbox-Automation, Meetingverarbeitung, Projekt-/Supportboards, Budgetfunktionen, OpenSpec-Delivery-Generierung, externe Systeme, Live Business Central, Project Twin oder Kundeninhalte.

## Release-Evidence

- `automation/Test-CustomerWorkspace.ps1`: read-only Validator und spezialisierte Routen.
- `automation/Test-WorkspaceSchemaParity.ps1`: maschinenlesbarer Schema-/Routen-Paritätsbericht.
- `automation/Test-WorkspaceValidator.ps1`: synthetischer Installations-, Positiv- und Negativlauf.
- `automation/Test-ProductContract.ps1`: Produktvertrag und Secret-/Tenant-Gates.
- OpenSpec strict für `spectra-workspace-validator`.

Candidate-Manifest und Payload-Digest dürfen erst nach diesem unreleased Commit lokal mit `New-ReleaseCandidate.ps1` erzeugt werden. Sie sind keine Veröffentlichung. Ein annotierter Tag, ein finaler Manifestzustand und ein Release werden ausschließlich im separaten Releaseprozess erzeugt.

## Gate

Der Projektagent liefert nur `GO_FOR_SEPARATE_ALPHA2_RELEASE_GATE`, wenn alle genannten Evidence grün und der Arbeitsbaum sauber sind. Andernfalls `NO-GO` mit stabilem Fehlercode. Nach alpha.2 beginnt ein neuer Change mit neuem Scope.
