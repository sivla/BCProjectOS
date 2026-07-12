# Blueprint-Versionierung und Aktualisierung

Status: Accepted for MVP 0

Der Blueprint verwendet Semantic Versioning. `workspace.yaml` speichert `blueprint_id`, `blueprint_version`, `schema_version`, `created_with_version` und `last_migrated_at`.

- Patch: rueckwaertskompatible Korrektur.
- Minor: additive Ordner, Felder oder Katalogwerte.
- Major: inkompatible Vertragsaenderung.

Jede Version besitzt Release Notes. Inkompatible oder strukturelle Aenderungen benoetigen eine versionierte, idempotente Migration mit Preflight, vorherigem Backup und Aenderungsprotokoll. Migrationen laufen nur explizit und ueberschreiben niemals blind kundeneditierbare Inhalte. Verwaltete Blueprint-Dateien und Kundendateien werden in einem spaeteren Blueprint-Manifest unterschieden.

Downgrade ist nicht garantiert; Restore ist der Rollbackweg. Der technische Spike unter `examples/bc-enterprise-blueprint/` wird fuer MVP 5/6 spaeter inventarisiert und nicht automatisch in Kundenworkspaces kopiert.

## Produktvertrag und installierbarer Blueprint

Spectra unterscheidet den versionierten Produktvertrag vom installierbaren Kundenworkspace-Blueprint. Das technische Repository bleibt BCProjectOS:

- `0.0.x` versioniert vor MVP 1 ausschliesslich den kundenunabhaengigen Produktvertrag. Ein solcher Release ist `CONTRACT_REFERENCE_ONLY` und darf keine installierte Blueprint-Version vortaeuschen.
- `0.1.0` bleibt dem ersten installierbaren Blank-Workspace nach Abschluss von MVP 1 vorbehalten.
- Release-Tags folgen `spectra-v<SemVer>` und muessen annotiert und unveraenderlich sein.
- Eine Bindung ist nur mit Tag, aufgeloestem Tag-Commit, Manifest-Source-Commit und SHA-256-Payload-Digest gueltig.
- Ohne vollstaendige Git-Historie, finalisiertes Manifest und Release-Tag bleibt der Verbraucherstatus `PENDING_BCPROJECTOS_RELEASE`.

## Verbindlicher Manifestvertrag

`schemas/release-manifest.schema.json` ist die maschinenlesbare Form des Release-Manifests. Ein installierbarer Blueprint muss mindestens `release_kind: installable_blueprint`, `manifest_state: final`, `consumer_mode: INSTALLABLE_BLUEPRINT`, `installable_blueprint: true`, eine mit `release_version` identische `blueprint_version`, einen vollstaendigen `source_commit` und den SHA-256-Digest des freigegebenen Produktumfangs enthalten.

Der Manifestinhalt speichert keinen `release_commit`, weil ein Commit seine eigene noch nicht erzeugte SHA nicht widerspruchsfrei enthalten kann. Die massgebliche Release-Bindung ist der extern gepruefte, annotierte Tag-Commit. Der `source_commit` muss dessen Vorfahr sein; der Produktumfang darf sich zwischen Source- und Tag-Commit nicht veraendern. Version, Tag, Manifest, Produktumfang und Digest muessen gemeinsam uebereinstimmen.

Neue Candidates verwenden Manifest-Schema v3. Sie binden ihre Produktquelle mit `candidate_source_commit` und `candidate_source_tree`; die finalen Felder `source_commit` und `source_tree` bleiben bis zur Promotion `null`. Candidates werden aus den Git-Blobs dieser Produktquelle berechnet und erzwingen `installable_blueprint: false` sowie `consumer_mode: CONTRACT_REFERENCE_ONLY`. Erst die getrennte Promotion verifiziert die Kandidatenprovenienz, entfernt die Kandidatenfelder und setzt finale `source_commit` und `source_tree`. Bereits veroeffentlichte finale Schema-v1-/Schema-v2-Manifeste bleiben kompatibel; alte Kandidaten muessen unter Schema v3 neu erzeugt werden.

Bereits veröffentlichte Schema-v1-Finalmanifeste bleiben unverändert prüfbar. Schema-v1-Candidates, Candidates ohne Source-Commit/Tree und frühere Candidates mit `installable_blueprint: true` sind nicht migrationsfähig und müssen unter dem Schema-v2-Vertrag neu erzeugt werden.

## Synthetische Vorab-Fixtures

Eine Vorab-Fixture ist kein Kundenworkspace und wird nicht gegen `workspace.schema.json` ausgegeben. Sie besitzt kein `workspace.yaml`, keine Kundenidentitaet und keine Produktversion. Ihre ausschliesslich testlokale Metadatei `synthetic-fixture.yaml` folgt `schemas/synthetic-workspace-fixture.schema.json` und belegt konstant `synthetic: true`, `installable: false` sowie `PENDING_BCPROJECTOS_RELEASE`. Erst echte Release-Evidence erlaubt die Erzeugung eines schema-validen Kundenworkspace mit releasegebundenen Versionsfeldern.

Die versionierten Dateien unter `examples/minimal-contract/` und `pilots/POV-001/` sind abgeschlossene synthetische Vertrags- beziehungsweise Pilot-Evidence. Ihre historischen Versionsfelder sind keine Release-Bindung, keine Vorab-Fixture im Sinn dieses Abschnitts und keine Eingabe fuer Generatoren oder Consumer. Neue Fixtures duerfen nur den hier definierten nicht-versionierten Vorab-Fixturetyp oder einen spaeter ausdruecklich normierten Fixturetyp verwenden.

## Maschinenlesbare Consumer-Bindung

`schemas/consumer-binding.schema.json` beschreibt die einzige portable Consumer-Aussage ueber einen Spectra-Stand. Sie verwendet genau zwei fail-closed Zustaende:

- `PENDING_BCPROJECTOS_RELEASE` identifiziert ausschliesslich `product_id: spectra` und die kanonische `repository_url`. Alle Releasewerte, einschliesslich Version, Tag, Tag-Commit, Manifestpfad, Source-Commit, Consumer-Modus, Installierbarkeit und Digest, sind `null`. Die Repository-URL allein ist kein Releasebeweis.
- `BOUND` ist nur nach externer Repository-Pruefung zulaessig. Der Consumer prueft einen annotierten Tag, dessen aufgeloesten `tag_commit`, das finale Manifest genau an diesem Commit, die gleiche Version und den gleichen Tag, den `manifest_source_commit` als Vorfahr, konsistenten Consumer-Modus und Installierbarkeit sowie den SHA-256-Payload-Digest. Das Manifest besitzt bewusst kein `release_commit`.

`automation/Test-ConsumerBinding.ps1` akzeptiert `BOUND` nur mit einem pruefbaren Repository-Root. Solange die erforderliche Evidence fehlt, ist ein strukturell aussehender BOUND-Datensatz kein akzeptierter Binding-Status.
