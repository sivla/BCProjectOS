# Projektwahrheit und Adapter-Provenienz

## Baseline–Angebot–Ist

Der Vertrag `schemas/project-reconciliation.schema.json` vergleicht einen versionierten Baseline-, Angebots- und Ist-Stand. Stunden, Rate und Betrag werden nicht unabhängig geglaubt: Der Validator berechnet die Beträge sowie die Abweichungen erneut. Jede Abweichung benötigt einen kontrollierten Grund und eine verständliche Begründung.

Ein Reconciliation-Datensatz ist weder Rechnung noch Buchung noch Nachweis produktiver Tätigkeit. `invoice_claim` und `productive_activity_claim` müssen immer `false` sein. Bei `synthetic-fixture` gehören alle Werte ausschließlich zur Testfixture. Bei `customer-workspace` bleibt die fachliche Wahrheit im Kundenworkspace.

Read-only-Prüfung:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 -Command validate-reconciliation -Workspace <workspace>
```

## Adapter-Provenienz

Der Vertrag `schemas/adapter-provenance.schema.json` bindet den relativen Quellblobpfad, den tatsächlichen Source-Hash, die Mappingversion, den relativen Projektionspfad und den tatsächlichen Projektionsdigest. Der Source-Hash vor und nach der Projektion muss identisch bleiben. Quellschreiben und stilles Überschreiben sind verboten.

Read-only-Prüfung:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Invoke-Spectra.ps1 -Command validate-provenance -Workspace <workspace>
```

Beide Befehle schreiben keine Datei und akzeptieren kein `-Apply`. Absolute Pfade, Traversal, Backslashes, fehlende Dateien und Hashabweichungen werden fail-closed abgelehnt.
