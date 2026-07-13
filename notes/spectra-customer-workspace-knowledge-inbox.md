# Quickstart: Kundenworkspace und Knowledge Inbox

Der aktuelle Block stellt ein vollständig synthetisches, kundenunabhängiges Beispiel bereit. Er verbindet sich nicht mit Jira, Confluence, Business Central oder einem Kunden-Repository.

## Dry-run und Erzeugung

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command generate-customer-knowledge -Workspace <ziel> -Profile implementation

powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command generate-customer-knowledge -Workspace <ziel> -Profile implementation -Apply
```

Für einen direkten Supportkontext ohne Projekt wird `-Profile support-only` verwendet.

## Read-only Validierung

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 `
  -Command validate-customer-knowledge -Workspace <ziel>
```

Der Validator prüft Kundenisolation, Umgebungs-/Gesellschafts-/Projekt-/Supportscopes, People und Rollen, Budgets, Lieferverpflichtungen, Intake-Hashes, Revisionen, Observations, Vergleiche, Proposals, menschliche Reviewentscheidungen, Stale-Zustände und null automatische Writes.

## Wahrheitsgrenze

- Synthetische Fixtures sind keine Kunden- oder Produktionsevidence.
- Reale Anzeigenamen entstehen ausschließlich im Kundenworkspace.
- Pending/unknown Rollen bleiben unbesetzt.
- Ein angenommener Proposal ist noch kein Ausführungsplan.
- Quellinhalte werden weder überschrieben noch automatisch in den kanonischen Stand übernommen.
