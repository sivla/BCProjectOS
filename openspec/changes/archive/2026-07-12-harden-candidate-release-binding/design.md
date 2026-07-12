# Design

## Zirkularitätsfreie Bindung

Der Quellcommit existiert vor der Candidate-Evidence und enthält keine Dateien unter `release/versions/<version>`. Der Generator liest ausschließlich seine Git-Blobs, speichert dessen vollständige SHA und Tree-SHA und erzeugt Manifest und Checksums im ausgeschlossenen Release-Metadatenbereich. Der spätere Candidate-Commit enthält daher nur Evidence und OpenSpec-Archivierung; sein eigener Commit muss und darf nicht im Manifest stehen.

## Manifestzustände

- Schema-v2-Candidate: `release_kind=installable_blueprint`, `consumer_mode=CONTRACT_REFERENCE_ONLY`, `installable_blueprint=false`, vollständiger `source_commit`, vollständiger `source_tree`.
- Schema-v2-Final: wird ausschließlich durch Promotion erzeugt und setzt `consumer_mode=INSTALLABLE_BLUEPRINT`, `installable_blueprint=true` sowie den dann aktuellen, extern tagbaren Source-Commit und Tree.
- Schema-v1-Final: bleibt zur Prüfung unveränderlicher historischer Releases zulässig.
- Schema-v1-Candidate: wird fail-closed als Legacy-Candidate abgewiesen.

## Payloadgrenze

Der Payload wird unverändert aus `release/release-scope.json` bestimmt. Manifest, Checksums, Release Notes, OpenSpec und der technische Spike liegen nicht im Produktdigest. Der Validator vergleicht den gebundenen Source-Payload zusätzlich mit dem aktuellen Commit und blockiert jede Payloadänderung nach der Source-Bindung.

## Promotion

Promotion akzeptiert nur einen committeden Schema-v2-Candidate, prüft Commit, Tree, Ancestry, Nicht-Selbstbezug, Blobchecksums und Digest und erzeugt erst danach ein finales installierbares Manifest. Tag und Veröffentlichung bleiben weiterhin getrennte, autorisierte Schritte.
