# Spectra (technisches Projekt: BCProjectOS)

## Portabler Spectra-Einstieg

Spectra wird aus einem echten annotierten `spectra-v<SemVer>`-Release außerhalb von Kundenrepositories installiert. Auf macOS ist PowerShell 7 (`pwsh`) die einzige Laufzeit; `install.sh` ist nur ein dünner Starter für `install.ps1`.

Der aktuelle veröffentlichte Vorabstand ist `spectra-v1.2.0-alpha.12`. Er ist plattformseitig für Windows und macOS gebunden; als Alpha bleibt er eine Vorabversion und ist keine automatische Kunden-Go-live-Freigabe.

```powershell
pwsh -NoProfile -File ./install.ps1 -Command install -SourceRoot <release-checkout> -Version <semver> -Apply -Approve
pwsh -NoProfile -File ./install.ps1 -Command doctor -Version <semver>
pwsh -NoProfile -File ./install.ps1 -Command init -Version <semver> -Workspace <workspace> -WorkspaceId <id> -ProjectId <project-id> -CustomerAlias <alias> -ConfigPath <config.json> -Apply -Approve
pwsh -NoProfile -File ./install.ps1 -Command adopt -Version <semver> -Workspace <workspace> -WorkspaceId <id> -ProjectId <project-id> -ConfigPath <config.json> -DiscoveryPath <discovery.json> -PlanPath <plan.json> -ExpectedPlanDigest <digest> -Apply -Approve
pwsh -NoProfile -File ./install.ps1 -Command register -Version <semver> -Workspace <workspace> -WorkspaceId <id> -ProjectId <project-id> -Apply -Approve
pwsh -NoProfile -File ./install.ps1 -Command validate -Version <semver> -Workspace <workspace>
pwsh -NoProfile -File ./install.ps1 -Command snapshot -Version <semver> -Workspace <workspace> -WorkspaceId <id> -ProjectId <project-id> -SnapshotPath <snapshot.json> -Apply -Approve
pwsh -NoProfile -File ./install.ps1 -Command uninstall -Version <semver> -Apply -Approve
```

Die vollständige Erklärung zu XDG-Pfaden, Registry, Projekttrennung, Secrets und Twin-Handoff steht in `contract/portable-bootstrap-project-registry.md`. Live-Atlassian-Apply bleibt gesperrt.

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

Die veröffentlichte Basis ist `spectra-v1.2.0-alpha.12`. Ein Arbeitsbaum, SemVer-Text, Kandidatenmanifest oder erwarteter Tag ist kein unveränderlicher Release-Nachweis. Der Readinessvertrag trennt Plattformbereitschaft, Onboardingbereitschaft und die ausschließlich im konkreten Kundenprojekt belegbare Go-live-Reife. Die deutsche Operatorführung steht in `notes/spectra-production-customer-onboarding.md`.

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

## Business-Central-Referenzbibliothek

Spectra registriert offizielle Microsoft-Dokumentation und BCApps, speichert Vendorinhalte aber ausschließlich in einem externen gemeinsamen Bare-Mirror-Cache. Exakte Locks und deterministische Indexe ermöglichen offline `status`, `build`, `search`, `show` und Snapshot-Diffs. Rolling Branches, unbelegte Objektbeschreibungen und stiller Onlinefallback werden abgelehnt.

Consumer-Bindungsvertrag pruefen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File automation/Test-ConsumerBindingFixtures.ps1
```

Die kanonische Repository-URL identifiziert nur das Produkt. Ohne extern geprueften annotierten Tag, dessen Commit, finales Manifest, Source-Ancestor und passenden SHA-256-Payload-Digest bleibt jeder Consumer bindend bei `PENDING_BCPROJECTOS_RELEASE`.

## Engagement und Fit-to-Standard

Spectra modelliert den fachlichen Einstieg einer BC-Einführung als zusammenhängenden Vertrag aus Angebot, Scope, Annahmen, Ausschlüssen, Phasen, Deliverables, RACI, Prozesslandkarten, E2E-Geschäftsfällen, Fit-/Gap-Assessments, Entscheidungen und offenen Fragen. Ein synthetisches Fixture kann mit `automation/New-SyntheticEngagementFitStandard.ps1` erzeugt und über `automation/Invoke-Spectra.ps1 -Command validate-engagement-fit-standard` strikt read-only geprüft werden. Steuer-, Rechts- und Kundenentscheidungen bleiben außerhalb des Produkt-Repositories.
