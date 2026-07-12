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

Die veröffentlichte Basis ist `spectra-v1.0.0-rc.1`. Nachgelagerte lokale Init- und Blueprintblöcke sind noch kein Bestandteil dieses Releases und bleiben bis zu ihrer getrennten Integration unveröffentlicht. Ein Arbeitsbaum, SemVer-Text, Kandidatenmanifest oder erwarteter Tag ist kein unveränderlicher Release-Nachweis.

Das Ziel bleibt der unabhängig geprüfte Hauptrelease `1.0.0`. Der aktuelle lokale Nachweis verbindet releasegebundenen Guided Init, profilgerechte Blueprints, Workspacevalidierung und Backup/Restore für Implementation und Support-only.

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

Der integrierte V1-Init-Pilot wird lokal so geprüft:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-SpectraV1IntegratedInitPilots.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-SpectraV1IntegratedInitEvidenceNegative.ps1
```

Die konkreten Operatorbefehle für beide Profile stehen in `notes/spectra-v1-integrated-init-quickstart.md`.

## Projektarten

Spectra trennt die technische Workspaceform von der fachlichen Projektart. Guided Init unterstützt `implementation`, `support`, `fit-gap` und `migration` mit kuratierten Blueprintempfehlungen. Optionale Vorgängerprojekte werden ausschließlich über eine stabile read-only Referenz verbunden; Inhalte werden weder kopiert noch verändert. Der Vertrag und die Übergänge sind in `notes/spectra-project-scenarios.md` beschrieben.

## Kundenworkspace und Knowledge Inbox

Der kundenbezogene Kern führt Umgebungen, Gesellschaften, optionale Projekte, direkte Supportfälle, Wissen, Budgets, Lieferverpflichtungen sowie kundeninstanzgebundene Personen und Rollen. Die Knowledge Inbox bindet lokale Quellen unveränderlich und erzeugt ausschließlich Observations, Vergleiche und Proposals. Auch angenommene Vorschläge verändern den Workspace nicht automatisch. Der synthetische Quickstart steht in `notes/spectra-customer-workspace-knowledge-inbox.md`.

## Dokumentprojektion

`generate-document-projection` erzeugt ausschließlich synthetische lokale Projektionen. `validate-document-projection` prüft beliebig viele Dokumentationsräume, Hierarchien, authored/generated-Eigentum, Provenienz und getrennte Jira-Sichten read-only. Die Materialisierung in Atlassian-Systeme ist ausdrücklich nicht Bestandteil dieses Vertrags.

Consumer-Bindungsvertrag pruefen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-ConsumerBindingFixtures.ps1
```

Die kanonische Repository-URL identifiziert nur das Produkt. Ohne extern geprueften annotierten Tag, dessen Commit, finales Manifest, Source-Ancestor und passenden SHA-256-Payload-Digest bleibt jeder Consumer bindend bei `PENDING_BCPROJECTOS_RELEASE`.

## Engagement und Fit-to-Standard

Spectra modelliert den fachlichen Einstieg einer BC-Einführung als zusammenhängenden Vertrag aus Angebot, Scope, Annahmen, Ausschlüssen, Phasen, Deliverables, RACI, Prozesslandkarten, E2E-Geschäftsfällen, Fit-/Gap-Assessments, Entscheidungen und offenen Fragen. Ein synthetisches Fixture kann mit `automation/New-SyntheticEngagementFitStandard.ps1` erzeugt und über `automation/Invoke-Spectra.ps1 -Command validate-engagement-fit-standard` strikt read-only geprüft werden. Steuer-, Rechts- und Kundenentscheidungen bleiben außerhalb des Produkt-Repositories.
