# Ticket Architecture

Diese Architektur wird zunaechst vollstaendig lokal umgesetzt. Ein spaeteres Zielsystem wie Jira oder Azure DevOps kann darauf abgebildet werden, ohne die fachlichen Source IDs zu aendern.

## Hierarchie

```text
Epic
  Story
    Task
```

### Epic

Ein Epic beschreibt ein fachliches Ergebnis oder einen zusammenhaengenden Unternehmensnutzen. Es ist kein Sammelbehaelter fuer beliebige technische Arbeit.

Pflichtfelder:

| Feld | Inhalt |
|---|---|
| External Key | Nach Veroeffentlichung vom Zielsystem |
| Source ID | Stabile OpenSpec- oder Projekt-ID |
| Titel | Fachliches Ergebnis in einem Satz |
| Business Outcome | Erwartete Wirkung und Messgroesse |
| Scope / Non-Scope | Klare Grenzen |
| Enterprise References | `GOAL-*`, `CAP-*`, `PROC-*`, `CASE-*` |
| Owner | Verantwortliche Rolle, keine erfundene Person |
| Definition of Done | Nachweisbarer Abschluss des Epics |

### Story

Eine Story beschreibt einen fuer eine Rolle erkennbaren, separat abnehmbaren Verhaltensbaustein. Eine OpenSpec-Requirement wird normalerweise zu einer Story; ihre Szenarien werden Akzeptanzkriterien.

Pflichtfelder:

| Feld | Inhalt |
|---|---|
| Source ID | Requirement-ID oder stabiler generierter Alias |
| Parent | Epic Source ID oder External Key |
| User Value | Rolle, Bedarf und Nutzen |
| Description | Fachliches Verhalten und Grenzen |
| Acceptance Criteria | Direkt aus WHEN/THEN-Szenarien |
| Business Rules | Referenzen auf `BR-*` |
| Dependencies | Andere Stories, Entscheidungen, Systeme |
| UAT References | Zugeordnete `UAT-*`-Faelle |

### Task

Ein Task beschreibt konkrete, pruefbare Arbeit fuer Umsetzung oder Lieferung. Tasks erzeugen keinen neuen fachlichen Scope.

Moegliche Typen:

- `AL Development`
- `Automated Test`
- `Configuration`
- `Data Migration`
- `Permission and Security`
- `Integration`
- `Documentation`
- `UAT Preparation`
- `Deployment`

Pflichtfelder: Parent Story, Task-Typ, Ergebnis, betroffene Komponenten, Abhaengigkeiten und Verifikationsschritt.

## OpenSpec-Mapping

| OpenSpec-Quelle | Ticket-Ziel |
|---|---|
| Delivery-Plan mit `epic.mode: existing` | Vorhandenes Epic referenzieren |
| Delivery-Plan mit `epic.mode: create` | Lokalen Epic-Entwurf erzeugen |
| Requirement | Story |
| Requirement Scenario | Akzeptanzkriterium |
| Design und `tasks.md` | Tasks |
| UAT-Fall | Story-Verknuepfung und Testreferenz |
| Release-Artefakt | Fix Version, Release oder Deployment-Referenz |

## Identitaet und Synchronisation

- `source_id` ist unveraenderlich und verhindert doppelte Tickets.
- `external_key` wird erst nach erfolgreicher Veroeffentlichung gespeichert.
- Aenderungen werden zuerst in OpenSpec vorgenommen und danach synchronisiert.
- Importierte Statuswerte aus dem Zielsystem duerfen nicht erfunden oder blind ueberschrieben werden.
- Publishing muss als Create, Update, Skip oder Conflict protokolliert werden.

## Lokale Ablage

```text
deliverables/<change-id>/tickets/
|-- epic.md
|-- stories/
|-- tasks/
|-- ticket-manifest.json
`-- validation-report.md
```

Der lokale Export ist die einzige erlaubte Ausgabe, solange keine externe Veroeffentlichung ausdruecklich freigegeben wurde.

## Statusmodell

Das interne Mindestmodell lautet `Draft`, `Ready`, `In Progress`, `Blocked`, `Review`, `Done`, `Rejected`. Die Abbildung auf Zielsystemstatus wird projektspezifisch konfiguriert.
