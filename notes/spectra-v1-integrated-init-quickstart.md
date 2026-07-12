# V1-Quickstart: releasegebundene Projektinitialisierung

Dieser Durchstich richtet sich an Operatoren, Projektleitung und Beratung. Er erzeugt keine Kundenevidence und verbindet sich nicht live mit Atlassian oder Business Central.

## 1. Antworten vorbereiten

Für ein Implementation-Projekt werden die Blueprints `BPC-CONFLUENCE-PROJECT`, `BPC-JIRA-PROJECT`, `BPC-BLANK-DOCUMENTS` und `BPC-METADATA` gewählt. Für Support-only bleibt die Struktur schlank: Projekt-Confluence, Jira und Metadaten; Consulting-Blankovorlagen werden nur bei tatsächlichem Bedarf ergänzt.

## 2. Initialisierung planen und ausführen

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command init -Workspace <ziel> -Guided -AnswersPath <antworten.json> `
  -Profile implementation -Version <gebundene-version> -CustomerAlias <alias> -ProductRoot <spectra-clone>

powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command init -Workspace <ziel> -Guided -AnswersPath <antworten.json> `
  -Profile implementation -Version <gebundene-version> -CustomerAlias <alias> -ProductRoot <spectra-clone> -Apply
```

Der erste Aufruf ist die Prüfung ohne Zieländerung. Apply erzeugt den Workspace atomar und nur aus einem final gebundenen Release.

## 3. Workspace prüfen

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command validate -Workspace <ziel> -ProductRoot <spectra-clone>
```

Die Prüfung ist read-only. Sie kontrolliert Releasebindung, Produktdigest, Pfade, Kataloge, Projektvertrag und Kundeninhaltsgrenzen.

## 4. Sicherung und Wiederherstellung

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command backup -Workspace <ziel> -Target <backup>
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command backup -Workspace <ziel> -Target <backup> -Apply
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command restore -Workspace <backup> -Target <leeres-ziel>
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command restore -Workspace <backup> -Target <leeres-ziel> -Apply
```

Nach der Wiederherstellung wird der Workspace erneut mit `validate` geprüft. Ein nicht leeres Ziel wird fail-closed abgelehnt und nicht verändert.

## 5. Profilgrenzen

- Implementation führt Engagement, Setup/Daten, UAT/Training/Defects und Betriebsübergabe als getrennte fachliche Records.
- Support-only beginnt bei Supportqualität und Betriebsübergabe; künstliche Implementierungsartefakte werden nicht vorsorglich erzeugt.
- Alle Pilotwerte sind synthetisch. Reale Kundenparameter, Freigaben und Evidence entstehen ausschließlich im Kundenworkspace.
