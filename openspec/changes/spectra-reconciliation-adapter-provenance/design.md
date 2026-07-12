# Design

## Gemeinsame Grenze

Beide Artefakte sind kundenunabhängige Dateiverträge. Sie liegen in einem Consumer-Workspace, nicht im Spectra-Produktwissen, und werden ausschließlich read-only geprüft. Die Repository-Fixtures verwenden klar synthetische IDs und Werte.

## Baseline–Angebot–Ist

`schemas/project-reconciliation.schema.json` definiert einen geschlossenen Vertrag. Baseline, Angebot und Ist besitzen jeweils eigene Version, Stunden, Rate und Betrag. Der Validator berechnet jeden Betrag als `hours × rate`, prüft die drei Differenzen des Ist-Stands zum Angebot und verlangt bei jeder Abweichung einen kontrollierten Grund plus Beschreibung. Die Wahrheitsgrenze unterscheidet `synthetic-fixture` und `customer-workspace`; Rechnungs- und Produktivbehauptungen müssen immer `false` bleiben.

## Adapter-Provenienz

`schemas/adapter-provenance.schema.json` beschreibt eine read-only Projektion. Der Validator löst ausschließlich sichere relative Pfade unterhalb des expliziten Fixture-/Workspace-Roots auf, prüft tatsächliche Git-unabhängige SHA-256-Dateibytes, Mappingversion, Projektionsdigest, unveränderten Vorher-/Nachher-Source-Hash und den Schreibschutz. Source und Projektion müssen verschiedene Pfade sein.

## CLI und Profile

`Invoke-Spectra.ps1` erhält die lesenden Befehle `validate-reconciliation` und `validate-provenance`. Apply ist für beide verboten. `New-SyntheticSpectra09Profile.ps1` erzeugt je Aufruf genau ein isoliertes Profil; Tests erzeugen beide Profile in getrennten Temp-Roots.

## Kompatibilität

Die neuen Dateien sind optional und ändern weder `workspace.schema.json` noch bestehende 0.8-Bindungen. Der vorhandene Backup-/Restore-Vertrag nimmt sie als reguläre allowlisted Dateien auf. Upgrade bleibt für kundeneigene Dateien unverändert fail-closed und überschreibt die neuen Artefakte nicht.
