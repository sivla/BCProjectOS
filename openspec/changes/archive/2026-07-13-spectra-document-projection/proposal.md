# Change: Generische Dokument- und Jira-Projektion

## Why

Spectra hält strukturierte Workspacefakten, besitzt aber noch keinen unabhängigen Vertrag für beliebige Dokumentationsräume und Jira-Sichten. Ein generischer Projektionsvertrag muss aus validierten Fakten reproduzierbare Ansichten erzeugen, ohne authored Inhalte zu überschreiben oder eine feste Confluence-Struktur zu erzwingen.

## What Changes

- Unabhängige Verträge `documentation = spaces + nodes + documents + references + provenance` und `jira = tickets + views`.
- Beliebig viele Spaces, Rootknoten und Hierarchien mit expliziten Home-Referenzen, Reihenfolge und Aufklappzustand.
- Strikte Eigentumsgrenze `generated|authored` mit vollständiger Provenienz für generierte Ansichten.
- Deterministischer lokaler Renderer, Schema, Validator, CLI-Routen sowie positive und isolierte negative Fixtures.
- Support-/Knowledge-only-Projektion ohne Projekt oder Jira bleibt gültig.

## Nicht-Scope

- Keine Live-Atlassian-Verbindung, Credentials, Plan/Apply/Verify-Materialisierung oder Rovo-Nutzung.
- Keine Kundeninhalte oder automatische Übernahme externer Blueprint-Candidates.
- Keine feste Drei-Space-Kardinalität und keine neue Releaseversion.
