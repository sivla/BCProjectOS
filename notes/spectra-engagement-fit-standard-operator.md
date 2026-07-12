# Operatorhinweis: Engagement und Fit-to-Standard

Ein vollständig synthetisches Fixture wird erzeugt mit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/New-SyntheticEngagementFitStandard.ps1 -Destination <temp-ziel>
```

Read-only validieren:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 -Command validate-engagement-fit-standard -Workspace <workspace>
```

Der Validator repariert nichts. Fehlercodes benennen fehlende Referenzen, RACI-Lücken, falsche Prozessreihenfolgen, unentschiedene Gaps und unzulässige Readinessbehauptungen. Steuer- und Rechtsfragen bleiben offen, bis eine autorisierte Kundenrolle eine belegte Antwort im Kundenworkspace erfasst; das Spectra-Produktfixture ist keine Beratung oder Kundenevidence.
