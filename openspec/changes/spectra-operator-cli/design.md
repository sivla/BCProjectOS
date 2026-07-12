# Design

`Invoke-Spectra.ps1` nimmt genau einen Befehl, einen expliziten Workspacepfad und optional `-Apply` entgegen. Ohne `-Apply` entstehen keine Workspaceänderungen. Jeder Aufruf liefert ein JSON-Objekt mit `product_id`, `command`, `mode`, `status`, `code` und `workspace`.

Die Dispatcherroute bleibt dünn und delegiert an bestehende, separat getestete Produktfunktionen. Die Pilotfixtures verwenden ausschließlich temporäre synthetische Verzeichnisse und beweisen Isolation der Profile `implementation` und `support-only`.
