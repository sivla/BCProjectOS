# Quickstart: Setup, Berechtigungen und Daten

## Consultant-Durchstich

1. Engagement-Scope und Fit-/Gap-Entscheidungen bestaetigen.
2. Setupschritte in Abhaengigkeitsreihenfolge bearbeiten.
3. Kundenparameter und bestaetigungspflichtige Lokalisierungs-/Steuerwerte sichtbar halten.
4. Rollenaufgaben, generische Permission-Needs, SoD-Konflikte und beide Proben dokumentieren.
5. Acht Datenvorlagen in drei Wellen ausschließlich per Dry-run pruefen.
6. Fehler korrigieren, Kontrollsummen abstimmen und Retest dokumentieren.

```powershell
powershell -File automation/Invoke-Spectra.ps1 -Command generate-setup-data -Workspace <ziel> -Profile implementation
powershell -File automation/Invoke-Spectra.ps1 -Command generate-setup-data -Workspace <ziel> -Profile implementation -Apply
powershell -File automation/Invoke-Spectra.ps1 -Command validate-setup-data -Workspace <ziel>
```

Ohne `-Apply` bleibt die Generierung ein schreibfreier Plan. Support-only verwendet `-Profile support-only`. Das Beispiel ist vollständig synthetisch und ersetzt keine Kunden-, Steuer-, Rechts- oder Berechtigungsentscheidung.
