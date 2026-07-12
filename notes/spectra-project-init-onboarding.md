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

## Projektspezifische Ticketstruktur

Das Init-Formular fragt die Ticketstrategie ab: `spectra-standard`, `project-mapping` oder `imported-readonly`. Eigene Vorgangstypen und Status werden nicht umbenannt, sondern über `mapping_version` auf stabile Spectra-Kategorien und Status abgebildet. Unbekannte Werte stoppen das Onboarding und werden als manuelle Mappingentscheidung sichtbar.

## Blueprint-Auswahl

`blueprints` enthält ausschließlich die Pakete, die im neuen Workspace benötigt werden. Spectra empfiehlt für Implementation alle vier Pakete und für Support-only die Confluence-, Jira- und Metadatenpakete. Kopiert werden dennoch nur explizit ausgewählte IDs:

- `BPC-CONFLUENCE-PROJECT`
- `BPC-JIRA-PROJECT`
- `BPC-BLANK-DOCUMENTS`
- `BPC-METADATA`

Damit bleibt ein kleines Support- oder Fit-Gap-Projekt schlank. Unterseiten werden nicht vorsorglich vervielfältigt, sondern nur als auswählbare Blankovorlagen bereitgestellt.
