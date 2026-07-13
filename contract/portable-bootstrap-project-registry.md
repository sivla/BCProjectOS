# Spectra auf einem neuen System betreiben

## Grundsatz

Spectra wird einmal als Produktrepository geklont und auf einen veröffentlichten annotierten Tag gestellt. Kundenprojekte bleiben getrennte Verzeichnisse unter einem lokalen Registry-Root. Spectra-Dateien werden nicht in Kundenrepositories kopiert.

Voraussetzungen:

- Git;
- Node.js;
- Windows PowerShell 5.1 oder PowerShell 7 auf Windows;
- PowerShell 7 (`pwsh`) auf macOS;
- ein veröffentlichter, finaler und installierbarer Spectra-Tag.

Auf macOS installiert Spectra keine Werkzeuge. `doctor` nennt bei fehlenden Voraussetzungen ausschließlich diese Homebrew-Hinweise: `brew install git`, `brew install node` und `brew install --cask powershell`. Alle Spectra-Aufrufe verwenden dort ausschließlich `pwsh`.

Ohne Argumente gelten auf macOS die XDG-konformen lokalen Standardpfade `~/.config/spectra/` für Konfiguration und `~/.local/share/spectra/` für Registry und lokale Daten. `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `-ConfigRoot` und `-RegistryRoot` dürfen sie überschreiben. Absolute Laufzeitpfade werden nie in versionierte Projektdateien geschrieben.

## Bootstrap und Doctor

```powershell
pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command bootstrap -Apply
pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command doctor -ProductRoot <spectra-clone> -Version 1.1.0-alpha.1
```

`doctor` ist read-only. Das Ergebnis nennt Windows- und macOS-Gates getrennt. Solange der Produktstand nicht auf einem echten macOS-Runner geprüft wurde, bleibt `macos_gate=MACOS_RUNNER_EVIDENCE_MISSING`.

## Ein Quickstart: init, adopt, register, validate, Snapshot-Handoff

Ein reales Projekt bleibt ein eigenes Repository. Spectra wird nicht hineinkopiert. Die portable Projektkonfiguration enthält Kundenalias, Projekt-ID und optional Jira-Site/Projekt/Board sowie Confluence-Site/Spaces/Root-Seiten. Sie enthält keine Tokens. Runtime-Secrets werden ausschließlich über `SPECTRA_*`-Umgebungsvariablen oder einen später autorisierten Keychain-Adapter referenziert; `.env`-Dateien werden weder erzeugt noch committed.

## Neues oder bestehendes Projekt

`init` delegiert an den releasegebundenen Spectra-Init. `adopt` delegiert an den vorhandenen Existing-Project-Adoption-Vertrag mit konfigurierbaren Jira-Projekt-/Board- und Confluence-Space-/Root-Bindungen. Beide registrieren den Workspace erst nach erfolgreichem Apply und Validate.

```powershell
pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command init -RegistryRoot <projects-root> -ProductRoot <spectra-clone> -Version 1.1.0-alpha.1 -Workspace <projects-root/customer-a> -WorkspaceId WS-CUSTOMER-A -ProjectId PRJ-CUSTOMER-A -Profile implementation -ConfigPath <init-config> -CustomerAlias CUSTOMER-A -Apply -Approve

pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command adopt -RegistryRoot <projects-root> -ProductRoot <spectra-clone> -Version 1.1.0-alpha.1 -Workspace <projects-root/customer-b> -WorkspaceId WS-CUSTOMER-B -Profile support-only -ConfigPath <adoption-config> -DiscoveryPath <discovery> -PlanPath <plan> -ExpectedPlanDigest <digest> -Apply -Approve

pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command register -RegistryRoot <projects-root> -ProductRoot <spectra-clone> -Version 1.1.0-alpha.1 -Workspace <projects-root/customer-b> -WorkspaceId WS-CUSTOMER-B -Profile support-only -Apply -Approve

pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command validate -RegistryRoot <projects-root> -Workspace <projects-root/customer-b>
```

Remote-Atlassian-Schreiben ist in diesem Block nicht implementiert. `-Remote` endet immer fail-closed. Secrets bleiben ausschließlich in der lokalen Laufzeitumgebung.

## Twin-Handoff

Ein bereits validierter Snapshot kann als read-only Handoff registriert werden. Persistiert werden nur relativer Pfad, SHA-256 und Releasebindung:

```powershell
pwsh -NoProfile -File automation/Invoke-SpectraBootstrap.ps1 -Command handoff -RegistryRoot <projects-root> -ProductRoot <spectra-clone> -Version 1.1.0-alpha.1 -Workspace <projects-root/customer-a> -WorkspaceId WS-CUSTOMER-A -ProjectId PRJ-CUSTOMER-A -SnapshotPath <projects-root/customer-a/incoming-snapshot.json> -Apply -Approve
```

Der Twin erhält keine Produktrepository- oder Credential-Pfade. Snapshotmanipulation blockiert `validate`.

Die macOS-Abnahme wird auf einem echten Mac mit `pwsh -NoProfile -File automation/Test-SpectraMacOSOnboarding.ps1 -OutputPath <evidence.json>` ausgeführt. Auf anderen Plattformen ist das Ergebnis ausdrücklich `PENDING/MACOS_RUNNER_EVIDENCE_MISSING`; ein Windows-Lauf kann kein macOS-PASS erzeugen.
