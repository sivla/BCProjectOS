# Blueprint-Versionierung und Aktualisierung

Status: Accepted for MVP 0

Der Blueprint verwendet Semantic Versioning. `workspace.yaml` speichert `blueprint_id`, `blueprint_version`, `schema_version`, `created_with_version` und `last_migrated_at`.

- Patch: rueckwaertskompatible Korrektur.
- Minor: additive Ordner, Felder oder Katalogwerte.
- Major: inkompatible Vertragsaenderung.

Jede Version besitzt Release Notes. Inkompatible oder strukturelle Aenderungen benoetigen eine versionierte, idempotente Migration mit Preflight, vorherigem Backup und Aenderungsprotokoll. Migrationen laufen nur explizit und ueberschreiben niemals blind kundeneditierbare Inhalte. Verwaltete Blueprint-Dateien und Kundendateien werden in einem spaeteren Blueprint-Manifest unterschieden.

Downgrade ist nicht garantiert; Restore ist der Rollbackweg. Der technische Spike unter `examples/bc-enterprise-blueprint/` wird fuer MVP 5/6 spaeter inventarisiert und nicht automatisch in Kundenworkspaces kopiert.

## Produktvertrag und installierbarer Blueprint

BCProjectOS unterscheidet den versionierten Produktvertrag vom installierbaren Kundenworkspace-Blueprint:

- `0.0.x` versioniert vor MVP 1 ausschliesslich den kundenunabhaengigen Produktvertrag. Ein solcher Release ist `CONTRACT_REFERENCE_ONLY` und darf keine installierte Blueprint-Version vortaeuschen.
- `0.1.0` bleibt dem ersten installierbaren Blank-Workspace nach Abschluss von MVP 1 vorbehalten.
- Release-Tags folgen `bcprojectos-v<SemVer>` und muessen annotiert und unveraenderlich sein.
- Eine Bindung ist nur mit Tag, aufgeloestem Tag-Commit, Manifest-Source-Commit und SHA-256-Payload-Digest gueltig.
- Ohne vollstaendige Git-Historie, finalisiertes Manifest und Release-Tag bleibt der Verbraucherstatus `PENDING_BCPROJECTOS_RELEASE`.

## Verbindlicher Manifestvertrag

`schemas/release-manifest.schema.json` ist die maschinenlesbare Form des Release-Manifests. Ein installierbarer Blueprint muss mindestens `release_kind: installable_blueprint`, `manifest_state: final`, `consumer_mode: INSTALLABLE_BLUEPRINT`, `installable_blueprint: true`, eine mit `release_version` identische `blueprint_version`, einen vollstaendigen `source_commit` und den SHA-256-Digest des freigegebenen Produktumfangs enthalten.

Der Manifestinhalt speichert keinen `release_commit`, weil ein Commit seine eigene noch nicht erzeugte SHA nicht widerspruchsfrei enthalten kann. Die massgebliche Release-Bindung ist der extern gepruefte, annotierte Tag-Commit. Der `source_commit` muss dessen Vorfahr sein; der Produktumfang darf sich zwischen Source- und Tag-Commit nicht veraendern. Version, Tag, Manifest, Produktumfang und Digest muessen gemeinsam uebereinstimmen.

## Synthetische Vorab-Fixtures

Eine Vorab-Fixture ist kein Kundenworkspace und wird nicht gegen `workspace.schema.json` ausgegeben. Sie besitzt kein `workspace.yaml`, keine Kundenidentitaet und keine Produktversion. Ihre ausschliesslich testlokale Metadatei `synthetic-fixture.yaml` folgt `schemas/synthetic-workspace-fixture.schema.json` und belegt konstant `synthetic: true`, `installable: false` sowie `PENDING_BCPROJECTOS_RELEASE`. Erst echte Release-Evidence erlaubt die Erzeugung eines schema-validen Kundenworkspace mit releasegebundenen Versionsfeldern.
