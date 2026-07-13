# Releasegebundener Projektstart

Ein realer Guided Apply benötigt einen final gebundenen Spectra-Release:

```powershell
powershell -File automation/Invoke-Spectra.ps1 -Command init `
  -Workspace <ziel> -Guided -AnswersPath <antworten.json> -Apply `
  -Profile implementation -Version <version> -CustomerAlias <alias> -ProductRoot <spectra-clone>
```

Spectra installiert den verifizierten Release und den Projektlayer vollständig im temporären Bereich. Erst nach Workspacevalidierung wird das Ergebnis atomar an das Ziel verschoben. Candidate, fehlender Tag, Profilabweichung und vorhandenes Ziel werden ohne Teilworkspace abgelehnt.

`-SyntheticPilot` bleibt der ausdrücklich nicht installierbare lokale Testpfad.
