# Spectra V1-Piloten und RC-Abnahme

Die Piloten prüfen den veröffentlichten Spectra-Release vollständig synthetisch und ohne Kundeninhalte.

## Implementation

Der Implementation-Pilot installiert einen gebundenen Workspace und führt Engagement/Fit-to-Standard, Setup/Berechtigungen/Daten, UAT/Training/Defects sowie Cutover/Hypercare/Handover aus. Anschließend werden Backup und Restore geprüft und alle Records read-only erneut validiert.

## Support-only

Der Support-only-Pilot beginnt bei kontrollierter Supportaufnahme. Er prüft Defect-/Evidence-, Hypercare-, Restart-, Recovery- und Handoverpfade ohne künstliche Implementierungsphasen.

## Ausführung

`powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-SpectraV1Pilots.ps1`

Ein RC-GO ist nur zulässig, wenn beide Profile, Upgrade, Recovery, deutsche Dokumentation und die Negativmatrix grün sind und keine offenen P1/P2 bestehen. Synthetische Ergebnisse sind keine Kunden- oder Produktivevidence.
