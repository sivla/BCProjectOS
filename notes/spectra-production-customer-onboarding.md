# Spectra für einen realen Kundenstart

## 1. Produkt prüfen

Installiere ausschließlich einen gebundenen `spectra-v<SemVer>`-Release außerhalb des Kundenrepositories und führe `doctor` aus. Der aktuelle veröffentlichte Plattformanker ist `spectra-v1.2.0-alpha.12`; Alpha bedeutet weiterhin Vorabversion.

## 2. Kunden-Input erfassen

Erforderlich sind stabile interne IDs, Projektart, BC-Betriebsart, Land/Lokalisierung, Umgebungsrollen, Atlassian-Betriebsmodus, Datenklassifikation, Retention, Intake-Regel und Runtime-Secretnamen. Nicht in dieses Repository gehören Kundennamen, Tenant-URLs, Zugangsdaten, echte Dateien, Steuerentscheidungen oder Abnahmen.

## 3. Planen und validieren

```powershell
pwsh -NoProfile -File automation/Invoke-ProductionCustomerOnboardingReadiness.ps1 -Command preflight -InputPath <onboarding.json>
pwsh -NoProfile -File automation/Invoke-ProductionCustomerOnboardingReadiness.ps1 -Command plan -InputPath <onboarding.json> -OutputPath <plan.json>
pwsh -NoProfile -File automation/Invoke-ProductionCustomerOnboardingReadiness.ps1 -Command validate -InputPath <onboarding.json>
```

Der Plan ist deterministisch und führt keine Kundenmutation aus. `simulated` und `manual-materialization` sind erlaubt; Live-Atlassian-Apply bleibt unsupported.

## 4. Operatorcheckliste

1. Releasebindung und Laufzeiten prüfen.
2. Separaten Kundenworkspace und Registry-Isolation anlegen.
3. Bei Brownfield zuerst read-only adoptieren, sonst init planen.
4. Workspace registrieren und validieren.
5. Upgradeplan, Backup und Restoreprobe belegen.
6. Externe Dateien nur unveränderlich in den Proposal-Intake aufnehmen.
7. Validierten Snapshot und Twin-Handoff erzeugen.
8. Supportweg und sicheren Uninstall ohne Kundendatenverlust prüfen.

## 5. Go-live-Grenze

Spectra kann keinen Kunden-Go-live freigeben. Tenant, Lizenzen, Zugänge, Kundendaten, Rollen/Berechtigungen, UAT, Cutover, erster Abschluss und Steuerfreigabe müssen im konkreten Projekt real belegt werden.

## Distribution

Ohne ausdrückliche Benutzerentscheidung zur Lizenz ist die Distribution `internal-only` und die Lizenzentscheidung `pending`. Ein Lizenztext wird nicht erfunden.
