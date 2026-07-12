# Geführter Spectra-Projektstart

Der interaktive Assistent fragt Projektmodus, Profil, BC-Prozesse, zentralen Projekt-Space, Zusammenarbeit, Ticketstrategie und Blueprintauswahl ab:

```powershell
powershell -File automation/Invoke-Spectra.ps1 -Command init -Workspace <ziel> -Guided
```

Der erste Lauf ist ein Dry-run. Mit `-ConfigOutput <datei>` bleibt die erzeugte Konfiguration zur Prüfung erhalten. `-Apply` erzeugt den lokalen Projektworkspace.

Automatisierte oder wiederholbare Projekte verwenden `-AnswersPath`. Eigene Ticketstrukturen benötigen eine relative, versionierte Mappingdatei. Zugangsdaten, Site-URLs und Tokens werden nicht abgefragt oder gespeichert.
