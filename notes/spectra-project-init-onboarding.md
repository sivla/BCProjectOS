# Spectra Projektinitialisierung und Bestands-Onboarding

## Schnellstart

Eine JSON-Konfiguration beschreibt Projektprofil, BC-Basic-Prozesse und Zusammenarbeit. Der zentrale `project_space` ist immer Pflicht. Weitere Bereiche werden nur als `read_only` referenziert.

```powershell
powershell -File automation/Invoke-Spectra.ps1 -Command init -Workspace C:\temp\projekt -ConfigPath C:\temp\init.json
powershell -File automation/Invoke-Spectra.ps1 -Command init -Workspace C:\temp\projekt -ConfigPath C:\temp\init.json -Apply
```

Der erste Aufruf ist ein Dry-run. `-Apply` schreibt atomar in ein leeres Ziel.

## Modi

- `new`: neuer Projektworkspace mit portablem Projekt-Space und Jira-Struktur.
- `local`: lokaler Workspace ohne Atlassian-Ziel.
- `onboard`: read-only Inventarisierung eines dateibasierten Exports.

Onboarding verändert die Exportquelle nicht. Live-Endpunkte, Tokens und Kundenwerte gehören nicht in Spectra. Eine spätere Live-Synchronisation benötigt einen eigenen geprüften Releasezyklus.
