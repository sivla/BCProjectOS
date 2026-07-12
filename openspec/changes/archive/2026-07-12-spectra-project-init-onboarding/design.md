# Design

`automation/Initialize-SpectraProject.ps1` verarbeitet eine JSON-Konfiguration, validiert sie fail-closed und erzeugt einen deterministischen Plan. `-Apply` schreibt ausschließlich atomar in ein noch nicht vorhandenes Ziel. Der Modus `onboard` liest einen expliziten lokalen Export read-only und übernimmt nur normalisierte Metadaten; Quelldateien bleiben unverändert.

Der zentrale Projekt-Space ist Pflicht. Zusätzliche Bereiche sind Referenzen mit `read_only=true`. Atlassian-Zielmodelle sind dateibasierte Verträge; Zugangsdaten und Live-Endpunkte sind nicht Teil des Modells.

`Invoke-Spectra.ps1 -Command init -ConfigPath ...` delegiert bei vorhandener Konfiguration an den neuen Initialisierer. Der bisherige releasegebundene Workspace-Init bleibt ohne `-ConfigPath` rückwärtskompatibel.
