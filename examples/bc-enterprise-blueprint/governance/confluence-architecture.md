# Confluence Architecture

Die Confluence-Architektur wird zunaechst als lokaler Seitenbaum erzeugt. Unternehmenswissen und OpenSpec bleiben die versionierte Quelle im Repository; eine spaetere Confluence-Synchronisation ist optional.

## Space-Struktur

```text
BC Enterprise Knowledge
|-- 00 Start und Navigation
|-- 10 Unternehmen
|   |-- Unternehmensprofil
|   |-- Strategie und Ziele
|   |-- Organisation und Glossar
|-- 20 Geschaeftsarchitektur
|   |-- Capability Map
|   |-- Prozesskatalog
|   |-- Geschaeftsfaelle
|   `-- Geschaeftsregeln
|-- 30 Anwendungslandschaft
|   |-- Systemlandkarte
|   |-- Business Central
|   |-- Integrationen
|   `-- Datenverantwortung
|-- 40 Projekte
|   `-- PRJ-001
|       |-- Projektauftrag
|       |-- Scope und Roadmap
|       |-- Entscheidungen
|       `-- Traceability
|-- 50 Changes und Releases
|   `-- Change-ID
|       |-- Change Overview
|       |-- Functional and Technical Design
|       |-- UAT
|       `-- Release Notes
`-- 60 Betrieb und Support
    |-- Deployment und Upgrade
    |-- Monitoring
    `-- Runbooks
```

## Seitentypen

| Seitentyp | Primaere Quelle | Aktualisierung |
|---|---|---|
| Unternehmensprofil | `company/` | Bei freigegebener Aenderung |
| Prozessseite | `business/processes/` | Bei Prozessfreigabe |
| Geschaeftsfall | `business/business-cases/` | Bei fachlicher Freigabe |
| BC Solution Overview | `application-landscape/business-central/` | Nach Architekturentscheidung oder Release |
| Projektseite | `projects/` | Bei Projektsteuerungsaenderung |
| Change Overview | OpenSpec Proposal und Business Context | Pro Change |
| Design | OpenSpec Design | Nach Review |
| UAT | OpenSpec UAT | Plan und spaeter belegtes Ergebnis |
| Release Notes | OpenSpec Release | Nach Releasefreigabe |

## Pflichtmetadaten jeder generierten Seite

- `source_id`
- `source_path`
- `source_revision`
- `content_status`
- `owner_role`
- `last_verified_at`
- `generated_at`
- `external_page_id` nach Veroeffentlichung

## Regeln

- Keine Seite darf durch Generierung automatisch als fachlich freigegeben gelten.
- Ist, Soll, Entwurf und implementierter Stand muessen sichtbar getrennt sein.
- Manuelle Confluence-Ergaenzungen duerfen bei Synchronisation nicht stillschweigend geloescht werden.
- Generierte Bereiche sollten markiert oder als vollstaendig verwaltete Seiten vereinbart werden.
- UAT-Ergebnisse, Freigaben und Deploymentstatus werden nur mit Nachweis veroeffentlicht.
- Keine Secrets, Tenant-IDs oder personenbezogenen Testdaten.

## OpenSpec-Mapping

| OpenSpec-Artefakt | Confluence-Seite oder Abschnitt |
|---|---|
| `proposal.md` | Change Overview |
| `business-context.md` | Business Context und Referenzen |
| `specs/` | Requirements und Akzeptanzkriterien |
| `design.md` | Functional and Technical Design |
| `tickets.md` | Delivery Plan und Ticket Links |
| `uat.md` | UAT Plan und spaeter Ergebnis |
| `documentation.md` | Anwender-, Admin- und Betriebsseiten |
| `training.md` | Schulungszweck, Lernpfade und lokale Schulungsunterlagen |
| `release.md` | Release Notes und Deploymentstatus |

## Lokale Ablage

```text
deliverables/<change-id>/confluence/
|-- 00-start/
|-- 10-unternehmen/
|-- 20-geschaeftsarchitektur/
|-- 30-anwendungslandschaft/
|-- 40-projekte/
|-- 50-changes-und-releases/
|-- 60-betrieb-und-support/
|-- 70-schulung/
|-- page-manifest.json
`-- validation-report.md
```

Jede lokale Seite ist Markdown mit einem Metadatenblock. Externe Page IDs bleiben leer.
