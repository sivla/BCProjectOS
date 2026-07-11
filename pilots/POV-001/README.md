# POV-001

Dieser Pilot prueft den BCProjectOS-Arbeitsablauf mit ausschliesslich synthetischen Daten. Er ist kein MVP-1-Generator und keine produktive Dateiverarbeitung.

`workspace/` ist der einzige Kundenworkspace des Piloten. `workspace/openspec/` ist sein einziger kanonischer OpenSpec-Root. Der kontrollierte Delivery-Lauf wird ueber eine explizite Bindung mit dem vorhandenen technischen Spike ausgefuehrt; dessen Engine wird nicht kopiert.

Ausfuehren:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File pilots/POV-001/automation/Test-POV001.ps1
```

Die finale Produktentscheidung wurde am 2026-07-11 als `Reduce` festgelegt. Diese Entscheidung gibt nur den reduzierten MVP-1-Umfang frei; der Pilot selbst bleibt abgeschlossen und unveraendert synthetisch.
