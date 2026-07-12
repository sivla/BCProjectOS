# Design

`New-ReleaseBoundProjectWorkspace.ps1` erstellt innerhalb eines temporären Verzeichnisses zunächst den releasegebundenen Basisworkspace und getrennt den validierten Projektlayer. Kollisionen werden fail-closed geprüft. Nur erlaubte identische OpenSpec-Konfigurationen werden zusammengeführt; die Projekt-README bleibt als `PROJECT-INIT.md` getrennt. Nach vollständiger `Test-CustomerWorkspace`-Prüfung wird das Ergebnis atomar an das noch leere Ziel verschoben.

Jeder Fehler entfernt ausschließlich das temporäre Verzeichnis. Ein vorhandenes Ziel wird niemals überschrieben. Guided Apply ohne `-SyntheticPilot` erfordert Version und Alias.
