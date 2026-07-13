# Design: Existing-Project-Adoption

## Fuehrender Ablauf

`Discovery-Export -> inspect -> configure -> validate -> plan -> adopt/apply(local)`

Discovery ist unveraenderlich und enthaelt Quellrevision, Erfassungszeit und Inhaltsdigest. Die Konfiguration bindet genau einen Workspace sowie eine Jira-Site/Projekt/Board-Kombination und eine oder mehrere Confluence-Space-/Root-Kombinationen. Mappingeintraege referenzieren ausschliesslich beobachtete Quellobjekte.

## Schichten

1. **Discovery** beschreibt beobachtete Jira- und Confluence-Metadaten ohne Inhalte als Kundenwahrheit zu deuten.
2. **Configuration** bindet Workspace, Produktquelle, Runtime-Secret-Schluessel und ausgewaehlte Quellobjekte.
3. **Mapping** ordnet Issue-Typen, Status, Felder, Spaces und Seitenrollen dem portablen Spectra-Modell zu.
4. **Plan** klassifiziert jede Entscheidung als `adopt-as-is`, `explicit-map` oder `improvement-proposal` und enthaelt nur idempotente lokale Operationen sowie nicht ausgefuehrte Remote-Vorschlaege.
5. **Apply** prueft Plan-Digest, Discovery-Revision und explizite Bestaetigung. Lokale Workspace-Erzeugung ist atomar. Remote-Operationen schlagen ohne spaeteren Adapter mit stabilem Code fehl.

## Sicherheitsgrenzen

- URLs muessen HTTPS-Origin ohne Credentials, Query oder Fragment sein.
- Pfade in versionierten Dateien sind sicher relativ; absolute Pfade und Traversal sind unzulaessig.
- Secretwerte sind verboten. Zulässig sind nur benannte Runtime-Schluessel.
- Source-Revision und Digest werden vor Planung und Apply erneut geprueft.
- `apply` ohne Plan, passenden Digest und Bestaetigung schreibt nichts.
- Geloeschte oder driftende Quellobjekte blockieren die Uebernahme.

## Wiederverwendung

Der lokale Apply-Pfad ruft die vorhandene Projektinitialisierung und Blueprint-Proposal-Grenze auf. Customer-Workspace, Information-Inbox und Blueprint V2 bleiben fuehrend. Der Adaptervertrag erweitert `external-system-boundaries.md`, implementiert aber keinen Live-Connector.

## Evidence und Commitgrenze

Der Proposal-Commit enthaelt nur OpenSpec. Der Implementierungscommit enthaelt Vertrag, Schemas, Generator/Validator, synthetische Tests und Dokumentation. Ein selbstgebundenes Releasecandidate-Manifest kann kryptografisch nicht im selben Sourcecommit liegen; deshalb bleibt die kanonische Release-Evidence ein nachgelagerter, separat freizugebender Commit.
