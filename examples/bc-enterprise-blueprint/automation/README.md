# Local Delivery Automation

Install the pinned local OpenSpec dependency once:

```powershell
npm install
```

## Generate

```powershell
powershell -ExecutionPolicy Bypass -File automation/Generate-Deliverables.ps1 -ChangeId <change-id>
```

Eine erneute Generierung benoetigt `-Force`. Vorhandene `evidence.json` wird dabei nicht ueberschrieben.

## Validate Gates

```powershell
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate Planning
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate BuildReady
powershell -ExecutionPolicy Bypass -File automation/Test-DeliveryGate.ps1 -ChangeId <change-id> -Gate ReleaseReady
```

Mit `-AsJson` entsteht maschinenlesbare Ausgabe. Ein blockiertes Gate liefert Exitcode `1`.

## Regression Test

```powershell
powershell -ExecutionPolicy Bypass -File automation/Test-Blueprint.ps1
```

Der Beispiel-Change muss Planning bestehen und bei BuildReady sowie ReleaseReady korrekt blockieren.
