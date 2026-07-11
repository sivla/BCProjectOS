# Kanonisches Entitaets- und Beziehungsmodell

Status: Accepted for MVP 0

## ID-Vertrag

IDs verwenden `<PREFIX>-<ULID>`, beispielsweise den rein synthetischen Wert `PRJ-01J00000000000000000000000`. Sie werden einmal vergeben, nie geaendert, nie wiederverwendet und sind innerhalb eines Kundenworkspace eindeutig. Titel, Slug, Pfad und externe Schluessel sind keine Identitaet. Der `CUS-*`-Wert ist der Namespace; Cross-Customer-Relationen sind verboten.

| Entitaet | Praefix | Kanonischer Ort |
|---|---|---|
| Kunde | `CUS` | `workspace.yaml` |
| Projekt | `PRJ` | `projects/<PRJ-ID>/project.yaml` |
| Supportfall | `SUP` | `support/cases/<SUP-ID>/case.yaml` |
| Meeting | `MTG` | `meetings/<MTG-ID>/meeting.yaml` |
| externe Datei | `FILE` | `external-files/register/<FILE-ID>.yaml` |
| Wissenselement | `KNO` | `knowledge/items/<KNO-ID>.md` |
| Geschaeftsprozess | `PROC` | `knowledge/processes/<PROC-ID>.md` |
| Geschaeftsregel | `BR` | `knowledge/business-rules/<BR-ID>.md` |
| Ticket | `TKT` | `work/tickets/<TKT-ID>.md` |
| Requirement | `REQ` | im kanonischen OpenSpec-Change |
| OpenSpec-Change | `CHG` | `openspec/changes/<slug>/change.yaml` |
| Evidence | `EVD` | `evidence/<EVD-ID>/evidence.yaml` |

Ein OpenSpec-Verzeichnis darf einen lesbaren Slug besitzen; die unveraenderliche Identitaet ist `CHG-*` in `change.yaml`. Ein Requirement bleibt in seinem Change. Evidence ist ein Nachweisdatensatz; eine zugehoerige Datei ist separat `FILE-*`.

## Gemeinsamer Minimalvertrag

Jede Entitaet besitzt `schema_version`, `id`, `customer_id`, `entity_type`, `title`, `lifecycle_status`, `created_at` und `relations`. Der Kunde selbst verwendet dieselbe ID fuer `id` und `customer_id`. Fachfelder werden nur von passenden Entitaetsschemas verlangt.

## Relationen

Relationen sind gerichtete Tupel aus `type` und `target_id`. Inverse Relationen werden berechnet und nicht doppelt gepflegt. Kontrollierte Typen und zulaessige Quell-/Zielarten stehen in `catalogs/relation-types.yaml`.

- `belongs_to`: jede Entitaet zum Kunden;
- `part_of_project`: Arbeitsobjekt oder Change zum Projekt;
- `concerns_case`: Meeting, Ticket, Change oder Evidence zum Supportfall;
- `source_file`: Wissen, Meeting oder Evidence zur externen Datei;
- `derived_from`: explizite Provenienz;
- `documents`: Wissens- oder Evidence-Bezug;
- `governs`: Geschaeftsregel zu Prozess oder Requirement;
- `implements`: Requirement zu Prozess oder Geschaeftsregel;
- `promoted_to`: Triggerobjekt zum Change;
- `contains_requirement`: Change zu Requirement;
- `tracks`: Ticket zu Arbeitsgegenstand;
- `evidences`: Evidence zum nachgewiesenen Gegenstand;
- `supersedes`: Nachfolge derselben fachlichen Entitaetsart.

Externe Systemschluessel stehen ausschliesslich in `external_refs`; sie sind weder Tags noch lokale IDs.
