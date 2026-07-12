# Spectra 0.10.0-alpha.1 – Candidate Notes

Status: `PENDING_BCPROJECTOS_RELEASE`

Dieser Stand ist ein source-/tree-gebundener, nicht installierbarer Candidate. Er ist weder promoviert noch getaggt oder veröffentlicht.

## Scope

- generischer Referenzgraph-Projektions- und Coverage-Vertrag;
- native und portable Relationsklassen mit deterministischer Zuordnung;
- kontrollierte Gründe für direkte, zusammengeführte, transformierte und ausgeschlossene Relationen;
- ehrliche Coverage-Semantik ohne 1:1- oder Vollständigkeitsbehauptung;
- Schema-v2-Candidatevertrag mit Commit-/Tree-Bindung und Selbstbezugsschutz.

## Evidence

- Source-Commit: `6adc740a36ee0ed43b662e6e66ece41bf59ba06f`
- Source-Tree: `929350fa9f326fcff9f98cf5a40ec65d614d3788`
- Payloaddateien: `110`
- Digestalgorithmus: `SHA-256`
- Payloaddigest: `ee21672c215de04cb7ae51f57b1d40ef95c79add1868f49c36d042f7cb9416df`

## Bekannte Grenzen

- Der Candidate ist `CONTRACT_REFERENCE_ONLY` und mit `installable_blueprint: false` nicht installierbar.
- Ein Coverage-Verhältnis von eins bedeutet vollständig erklärte native Relationen, nicht zwingend eine 1:1-Projektion oder vollständige portable Repräsentation.
- Alle Repository-Fixtures sind synthetisch; sie sind keine Kunden-, Live-System- oder Produktivevidence.
- Der historische technische Spike ist ausdrücklich vom Produktpayload ausgeschlossen. Seine vorbestehenden Checkout-Zeilenenden sind keine Candidate-Payload-Evidence.
- Promotion, finales installierbares Manifest, annotierter Tag und GitHub-Prerelease benötigen eine getrennte Kontrollfreigabe.
- Vollständige Spectra-1.0-RC-/Pilotevidence bleibt ein Folgeumfang.
