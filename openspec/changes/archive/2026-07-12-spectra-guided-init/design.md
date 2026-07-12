# Design

`New-SpectraInitConfiguration.ps1` besitzt zwei Eingänge: interaktive Konsole oder versionierbare Answer-Datei. Beide erzeugen exakt denselben `project-init.schema.json`-Vertrag. Komplexe eigene Ticketstrukturen und zusätzliche Spaces werden aus expliziten lokalen JSON-Dateien gelesen; ihre Inhalte werden anschließend durch den bestehenden Init-Vertrag validiert.

`Invoke-Spectra.ps1 -Command init -Guided` erzeugt die Konfiguration temporär oder unter `-ConfigOutput` und delegiert anschließend unverändert an `Initialize-SpectraProject.ps1`. Dry-run bleibt Standard.
