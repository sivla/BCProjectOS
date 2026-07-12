# Change: Integrierte V1-Init-Piloten

## Why

Releasegebundener Guided Init, Blueprint-Katalog und die fachlichen V1-Verträge sind einzeln belegt. Für den stabilen Hauptrelease fehlt noch ein zusammenhängender Bediennachweis: Ein unabhängiger Operator muss beide Profile aus einem gebundenen Release initialisieren, validieren, sichern und wiederherstellen können, ohne verborgenes Wissen oder Kundeninhalte.

## What Changes

- Zwei isolierte synthetische End-to-End-Piloten für `implementation` und `support-only`.
- Profilgerechte Blueprint-Auswahl mit bewusst schlankem Supportprofil.
- Fachliche Generator-/Validatorstrecke, Backup/Restore und Recovery im erzeugten Workspace.
- Maschinenlesbare, releasegebundene Pilot-Evidence mit stabilen Negativcodes.
- Deutscher Quickstart mit reproduzierbaren Operatorbefehlen.
- Ehrliche Aktualisierung der V1-Gap-Matrix.

## Nicht-Scope

- Keine neue Fachfunktion, Version, Candidate- oder Releasebehauptung.
- Keine Live-Atlassian-Verbindung und keine Kundeninhalte.
- Keine Änderung am eingefrorenen RC2-Candidate oder an veröffentlichten Releases.
