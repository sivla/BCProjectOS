# Spectra Operator CLI

Spectra 0.8.0-alpha.1 vereinheitlicht die vorhandenen Operatorflüsse unter einer deterministischen Dispatcheroberfläche. Der Block bleibt kundenunabhängig und verwendet ausschließlich synthetische, isolierte Pilotworkspaces.

## Scope

- Befehle für `init`, `validate`, `plan-upgrade`, `upgrade`, `backup`, `restore` und `candidate-check`;
- Dry-run als Standard und explizites Apply für schreibende Operationen;
- stabile JSON-Ergebnisse und Fehlercodes;
- isolierte Implementation- und Support-only-Piloten;
- Wiederanlauf-/Rollback- und negative Dispatcherfixtures.

## Nicht-Scope

Keine Live-Systeme, Kundendaten, Veröffentlichung, Tags oder finales Releasemanifest.

## SemVer

Die einheitliche Operatoroberfläche ist eine rückwärtskompatible neue Fähigkeit gegenüber 0.7.0-alpha.1. Der erwartete, noch nicht veröffentlichte Kandidat ist `0.8.0-alpha.1`.
