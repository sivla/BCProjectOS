# Design

Schema 3 trennt Kandidatenprovenienz von finaler Releaseprovenienz. Generator und Validator verwenden fuer `manifest_state=candidate` ausschließlich `candidate_source_commit/tree`. Promotion verifiziert diese Bindung und entfernt sie beim Erzeugen des finalen Manifests; anschließend bezeichnet `source_commit/tree` wieder eindeutig die finale Promotionquelle. Alte finale Schema-1-/Schema-2-Manifeste bleiben kompatibel, alte Kandidaten werden fail-closed abgelehnt und muessen neu erzeugt werden.
