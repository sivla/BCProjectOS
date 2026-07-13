# Generische Dokument- und Jira-Projektion

## Requirements

### Requirement: Dokumentation ist beliebig hierarchisch
Spectra MUST 1..N Spaces, beliebig viele Rootknoten und explizite Home-Referenzen ohne feste Kunden- oder Projekttopologie validieren.

### Requirement: Generierte und authored Inhalte bleiben getrennt
Spectra MUST generierte Dokumente vollständig an Blueprint, Quellrevisionen, Snapshot, Digest und Erzeugungszeit binden und authored Dokumente vor Überschreibung schützen.

### Requirement: Referenzen und Provenienz sind fail-closed
Spectra MUST Zyklen, doppelte IDs oder Orders, unbekannte Parents/Dokumente, Cross-Customer-Referenzen, unsichere Origins und fehlende Provenienz ablehnen.

### Requirement: Renderer bleibt lokal und deterministisch
Spectra MUST gleiche validierte Eingaben byteidentisch rendern und darf authored Dateien nicht überschreiben.
