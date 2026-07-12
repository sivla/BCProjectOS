# Design

`Invoke-Spectra.ps1` nimmt genau einen Befehl, einen expliziten Workspacepfad und optional `-Apply` entgegen. Ohne `-Apply` entstehen keine Workspaceänderungen. Jeder Aufruf liefert ein JSON-Objekt mit `product_id`, `command`, `mode`, `status`, `code` und `workspace`.

Die Dispatcherroute bleibt dünn und delegiert an bestehende, separat getestete Produktfunktionen. Die Pilotfixtures verwenden ausschließlich temporäre synthetische Verzeichnisse und beweisen Isolation der Profile `implementation` und `support-only`.

## Lernkandidaten

Die anonymisierten Befunde `SPECTRA-LEARN-BASELINE-001`, `SPECTRA-LEARN-ADAPTER-001` und `SPECTRA-LEARN-GRAPH-001` sind fail-closed bewertet. Baseline-/Ist-Reconciliation und Adapter-Provenienz bleiben wegen fehlender commitgebundener Herkunftsevidence `deferred`; die native/portable Graphtrennung ist durch den veröffentlichten Spectra-0.7-Vertrag generisch belegt und `accepted`. Keine Entscheidung erweitert den aktuellen Dispatcher-Scope. Evidence: `notes/spectra-0.8-learning-candidates.md`.
