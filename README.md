# Spectra (technisches Projekt: BCProjectOS)

Spectra ist der wiederverwendbare, kundenunabhaengige Produktvertrag fuer Business-Central-Projekte und Supportarbeit. Dieses Repository enthaelt den normativen Vertrag, einen synthetischen Proof of Value, einen technischen Referenz-Spike und die OpenSpec-Vorhaben fuer die weitere Produktentwicklung. Das technische Repository und Projekt heissen weiterhin BCProjectOS.

Es ist keine Kundeninstanz, kein Kontrollzentrum und kein Project Twin. Reale Kundenwahrheit, Kundendaten und Kunden-Evidence gehoeren ausschliesslich in die jeweilige Kundeninstanz.

## Verbindliche Bereiche

- `contract/` definiert Produktgrenze, Datenmodell und Governance.
- `catalogs/` enthaelt kontrollierte Werte in einer JSON-kompatiblen YAML-1.2-Teilmenge.
- `schemas/` beschreibt die maschinenlesbaren Mindestvertraege.
- `examples/minimal-contract/` ist ausschliesslich synthetische Vertrags-Evidence.
- `tests/invalid/` belegt kritische fail-closed Ablehnungen.
- `openspec/` ist der einzige OpenSpec-Root dieses Produkt-Repositories.
- `pilots/POV-001/` dokumentiert den abgeschlossenen synthetischen Proof of Value mit der Entscheidung `Reduce`.
- `examples/bc-enterprise-blueprint/` ist ein unveraenderter technischer Referenz-Spike fuer spaetere MVPs.

## Aktueller Status

Der reduzierte MVP-1-Change `define-reduced-bcprojectos-mvp1` ist in Arbeit. Vor einem echten installierbaren Release erzeugt `automation/New-CustomerWorkspace.ps1` ausschliesslich explizite, nicht installierbare synthetische Fixtures.

Der Release-Status bleibt ehrlich:

```text
PENDING_BCPROJECTOS_RELEASE
```

Ein Arbeitsbaum, SemVer-Text, Kandidatenmanifest oder erwarteter Tag ist kein unveraenderlicher Release-Nachweis.

## Lokale Verifikation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-ProductContract.ps1
```

Synthetische Fixture in einem test-eigenen Ziel erzeugen und pruefen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/New-CustomerWorkspace.ps1 `
  -Destination <lokaler-testpfad> `
  -Profile implementation `
  -SyntheticFixture

powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-SyntheticWorkspaceFixture.ps1 `
  -Path <lokaler-testpfad>
```

OpenSpec streng pruefen:

```powershell
openspec validate define-reduced-bcprojectos-mvp1 --strict
```

Consumer-Bindungsvertrag pruefen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-ConsumerBindingFixtures.ps1
```

Die kanonische Repository-URL identifiziert nur das Produkt. Ohne extern geprueften annotierten Tag, dessen Commit, finales Manifest, Source-Ancestor und passenden SHA-256-Payload-Digest bleibt jeder Consumer bindend bei `PENDING_BCPROJECTOS_RELEASE`.
