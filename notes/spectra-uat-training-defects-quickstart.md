# Quickstart: UAT, Training und Defects

## Fachlicher Ablauf

1. Entry-Kriterien und sieben BC-Basic-Kernprozesse bestätigen.
2. Positive, negative und Ausnahmefälle durchführen.
3. Abweichungen als reproduzierbare Defects triagieren.
4. Fix und Retest mit synthetischer Evidence verbinden oder einen Waiver entscheiden.
5. Rollenbezogene Übungen, Fehlersituationen, Kompetenznachweis und Operator-Smoke abschließen.
6. Exit nur bei vollständiger Abdeckung und null offenen P1/P2 entscheiden.

```powershell
powershell -File automation/Invoke-Spectra.ps1 -Command generate-uat-training-defects -Workspace <ziel> -Profile implementation
powershell -File automation/Invoke-Spectra.ps1 -Command generate-uat-training-defects -Workspace <ziel> -Profile implementation -Apply
powershell -File automation/Invoke-Spectra.ps1 -Command validate-uat-training-defects -Workspace <ziel>
```

Ohne `-Apply` bleibt die Generierung schreibfrei. `support-only` nutzt denselben Qualitätsvertrag für Regression, Schulung und Defect-Nachweis. Alle Beispiele sind synthetisch; Sandbox, UI-Profil und Testautomation sind keine Produktions-, Berechtigungs- oder Kundenfreigabe.
