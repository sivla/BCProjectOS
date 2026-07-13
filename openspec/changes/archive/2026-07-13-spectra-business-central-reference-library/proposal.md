# Change: Business-Central-Referenzbibliothek

## Why

Spectra benötigt für Beratung, Setup, Tests, Schulung, Support und Browserplanung ein lokales, quellgebundenes BC-Wissen. Rolling Vendor-Branches und zeitlose Vollständigkeitsbehauptungen sind dafür ungeeignet. Die Produktgrenze braucht einen versionierten Registry-, Cache-, Lock-, Index- und Queryvertrag.

## What Changes

- Positivgelistete Registry für offizielle Microsoft-Dokumentation und BCApps.
- Gemeinsamer, konfigurierbarer Vendor-Cache außerhalb von Produkt- und Kundenrepos mit Bare-Mirrors und unveränderlichen Locks.
- Versionierter Knowledge-Pack- und Objektkatalog für exakte BC-Version, Country und installierte Apps.
- Deterministischer AL-/Dokumentparser, Filter-/Queryvertrag, Diffbericht und Offline-Nutzung des letzten validierten Snapshots.
- Fail-closed CLI für `status`, `plan-update`, `build`, `search` und `show`; Onlineupdate bleibt explizit und schreibt nur in den Cache.

## Nicht-Scope

- Keine Vendorinhalte, Submodule, Kundenwerte, Credentials oder absolute Cachepfade im Produktpayload.
- Keine Vektor-/MCP-Suche, kein stiller Onlinefallback und keine Vollständigkeitsbehauptung für rolling `main`.
- Keine Änderung an Kundenworkspaces oder dem Dokumentprojektionsvertrag.
