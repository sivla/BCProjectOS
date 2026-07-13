# Operatorhinweis: BC-Referenzbibliothek

`SPECTRA_KNOWLEDGE_ROOT` verweist auf einen gemeinsamen lokalen Vendor-Cache außerhalb aller Produkt- und Kundenrepositories. `sources/*.git` enthält ausschließlich Bare-Mirrors. `locks/<snapshot>/sources.lock.json` bindet jeden nutzbaren Stand an Commit, Tree, Lizenz und Inhaltsdigest. Ohne validierten Lock und Index gibt es keinen Queryfallback.

Der synthetische Nachweis bildet BC 28.2 mit Plattform 28.0.52048.0, Anwendung 28.2.50931.52241, AL-Runtime 17.0 sowie W1/DE und zwei installierte Apps ab. Diese Werte sind eine generische Versionsfixture, keine Kunden- oder Tenantinformation.

Beispiele:

```powershell
$env:SPECTRA_KNOWLEDGE_ROOT = '<gemeinsamer-cache>'
powershell -File automation/Invoke-BusinessCentralKnowledge.ps1 -Command status -SnapshotId <snapshot>
powershell -File automation/Invoke-BusinessCentralKnowledge.ps1 -Command build -SnapshotId <snapshot> -Apply
powershell -File automation/Invoke-BusinessCentralKnowledge.ps1 -Command search -SnapshotId <snapshot> -Query Einkauf -Country DE
```

`plan-update` ist read-only. `update -Apply` darf ausschließlich den gemeinsamen Cache verändern und erzeugt noch keinen validierten Snapshot. Erst ein separat erzeugter Lock macht eine Quelle nutzbar. Tokens, Authstates, Tenant-, Session- und Telemetriewerte sind verboten.
