# Design: Portables Bootstrap und Projektregister

## Laufzeitgrenze

Der Spectra-Produktclone bleibt unverändert und kann read-only an beliebiger Stelle liegen. Kundenworkspaces liegen unter einem expliziten Registry-Root außerhalb des Produktclones. Persistiert werden nur POSIX-normalisierte relative Pfade zum Registry-Root; absolute Pfade existieren ausschließlich im aktuellen Prozess.

## Befehle

- `doctor`: prüft Produktroot, Git, PowerShell, Releasebindung, Registry-Root und Plattformgate ohne Writes.
- `register`: nimmt einen bereits validierten Workspace idempotent in die lokale Registry auf.
- `init`: delegiert an den vorhandenen releasegebundenen Init und registriert erst nach erfolgreicher Validierung.
- `adopt`: delegiert an den vorhandenen Offline-Adoption-Vertrag und registriert erst nach erfolgreichem Apply.
- `handoff`: schreibt atomar einen read-only Twin-Handoff in den Workspace.
- `validate`: validiert Registry, Workspacebindungen und Handoff fail-closed.

## Plattformmodell

Pfadnormalisierung verwendet `System.IO.Path`, speichert aber ausschließlich `/` als Separator. Traversal, Rootpfade, Laufwerkspräfixe, UNC, Symlinks/Reparsepunkte und Pfade außerhalb des Registry-Roots werden abgelehnt. Windows und macOS wurden für den unveränderlichen Release `spectra-v1.2.0-alpha.12` in GitHub Actions Run `29293515568` erfolgreich geprüft.

## Wahrheits- und Sicherheitsgrenze

Die Registry enthält IDs, Profil, relative Workspaceposition und Produktbindung, keine Kundendokumente. Der Twin-Handoff referenziert einen validierten Snapshot relativ zum Workspace und bindet dessen SHA-256. Jira-/Confluence-Ziele bleiben in `governance/adoption-config.json`; Runtime-Secrets werden nie übernommen.

## Snapshot-Store und Multi-Kunden-Katalog

Jedes Projekt besitzt `snapshots/releases/<snapshot-id>/snapshot.json`, ein digestgebundenes `release.json` und einen atomar aktualisierbaren `snapshots/current.json`-Zeiger. Releaseobjekte sind immutable; eine Korrektur erzeugt einen neuen Snapshot. Der lokale Katalog referenziert ausschließlich freigegebene Release-Manifeste und prüft Customer-/Project-Isolation.

Der Snapshot enthält Source Inventory, Confluence-Bindungen, Delta, Tombstones, Wissensänderungssätze, Coverage, Widersprüche und Brownfield-Reconciliation. Ungeprüftes Wissen bleibt Proposal und darf nicht als Wahrheit projiziert werden. Interne und kundenspezifische Views werden explizit getrennt.

Filesystem und HTTP transportieren dasselbe `snapshot.json` mit demselben Schema-Identifier, Media Type und Payloaddigest. HTTP ist nur ein portabler Transportvertrag; dieser Block startet keinen Server. `source_commit` ist ausschließlich ein optionales Feld unter `provenance` und erscheint weder im Katalogschlüssel noch in der Twin-Laufzeitadresse.
