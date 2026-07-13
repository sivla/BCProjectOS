# Portabler Snapshot- und Multi-Kunden-Vertrag

Spectra trennt Kundeninstanz, Projektworkspace, Snapshot-Release und Project-Twin-Katalog. Ein Snapshot ist ein immutable, validierter Projektstand. `current.json` ist nur ein austauschbarer Zeiger auf ein unveränderliches Release; Korrekturen erzeugen ein neues Release.

## Quellen und Änderungen

Das Source Inventory bindet stabile Quellobjekte, Version, normalisierten Inhalts-Hash, relative Herkunft und Sync-Checkpoint. Confluence-Seiten binden zusätzlich Space, Parent und Attachment-Digests. Delta verwendet ausschließlich `added`, `modified`, `renamed`, `moved`, `deleted`, `inaccessible` und `conflicted`. Für `deleted` und `inaccessible` ist ein Tombstone Pflicht.

Wissensänderungssätze bleiben bis zum Review Vorschläge. Nur `accepted` darf `projected_as_truth=true` setzen. Coverage, Widersprüche sowie Brownfield-Import-/Ausschlussmatrix zeigen bekannte und offene Bereiche; sie erfinden keine Vollständigkeit.

## Isolation und Transport

Der Multi-Kunden-Katalog referenziert je Kunde und Projekt ausschließlich ein freigegebenes Snapshot-Release. Customer- und Project-ID müssen durch Katalog, Release und Snapshot identisch sein. Interne Artefakte dürfen nicht in kundenspezifischen Views erscheinen.

Filesystem und HTTP liefern exakt dieselben `snapshot.json`-Bytes unter `spectra-portable-project-snapshot-v1` und demselben SHA-256. HTTP ist in diesem Block nur ein Transportvertrag, kein Server. `source_commit` ist optionale Snapshot-Provenienz; der Twin verwendet Release-ID, relative Ressource und Digest statt Git als Laufzeitschnittstelle.
