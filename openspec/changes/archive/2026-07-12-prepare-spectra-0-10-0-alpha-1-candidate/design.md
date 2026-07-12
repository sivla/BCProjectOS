# Design

## Source-Bindung

Der Candidate bindet exakt `source_commit=6adc740a36ee0ed43b662e6e66ece41bf59ba06f` und `source_tree=929350fa9f326fcff9f98cf5a40ec65d614d3788`. Der Source-Commit enthält noch keine eigene Candidate-Evidence. Manifest, Checksums, Release Notes und OpenSpec liegen außerhalb des in `release/release-scope.json` definierten Produktpayloads.

## Candidatezustand

Das Manifest verwendet Schema v2, `manifest_state=candidate`, `consumer_mode=CONTRACT_REFERENCE_ONLY` und `installable_blueprint=false`. Es ist trotz Commit-/Tree-Bindung weder installierbar noch veröffentlicht. Promotion, finales Manifest, Tag und GitHub-Prerelease benötigen eine getrennte Kontrollfreigabe.

## SemVer

`0.10.0-alpha.1` ist ein Minor-Schritt gegenüber `0.9.0-alpha.1`, weil der Referenzgraph-Coverage-Vertrag eine additive Produktfähigkeit ist. Alpha bleibt angemessen, weil die vollständige 1.0-RC-/Pilot-Evidence noch nicht abgeschlossen ist.

## Reproduzierbarkeit

Der Generator liest ausschließlich Git-Blob-Bytes des Source-Commits. Der Candidate-Commit darf nur ausgeschlossene Release-/OpenSpec-Evidence ergänzen. Der Validator vergleicht Source und Candidate-HEAD erneut und blockiert jede Payloadänderung, falschen Tree, manipulierten Digest oder Selbstbezug.
