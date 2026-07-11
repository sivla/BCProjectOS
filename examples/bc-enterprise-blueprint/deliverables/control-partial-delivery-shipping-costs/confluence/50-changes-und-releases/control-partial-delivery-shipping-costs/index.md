<!-- generated: bc-enterprise-blueprint; source-change: control-partial-delivery-shipping-costs; do-not-edit -->
# Change Overview

# Versandkosten bei Teil- und Nachlieferungen steuern

## Why

Der Geschaeftsfall `CASE-O2C-001` enthaelt noch keine freigegebene und systemseitig pruefbare Regel fuer Versandkosten bei mehreren Lieferungen. Der Change dient als Beispiel, wie eine solche Wissensluecke vor einer BC-Implementierung kontrolliert behandelt wird.

## What Changes

- Die fachliche Versandkostenregel wird mit dem Process Owner entschieden.
- Business Central soll die freigegebene Regel nachvollziehbar anwenden.
- Automatisierte Tests, UAT, Tickets und Dokumentation werden aus derselben Anforderung abgeleitet.
- Es wird keine konkrete Berechnungsvariante angenommen, solange `BR-SALES-001` nicht freigegeben ist.

## Capabilities

### New Capabilities

- `partial-delivery-shipping-cost-control`: Steuerung und Nachweis der Versandkostenbehandlung bei Teil- und Nachlieferungen.

### Modified Capabilities

Keine.

## Enterprise References

- Projekt: `PRJ-001`
- Ziel: `GOAL-001` (noch zu konkretisieren)
- Capability: `CAP-SALES-001`
- Prozess: `PROC-O2C-001`
- Geschaeftsfall: `CASE-O2C-001`
- Regel: `BR-SALES-001`

## Non-Goals

- Keine produktive BC-Konfiguration oder Veroeffentlichung.
- Keine Festlegung einer fachlichen Regel ohne Owner-Freigabe.
- Keine Verarbeitung echter Kunden- oder Auftragsdaten.

## Impact

Potentiell betroffen sind Verkaufsbelege, Lieferbuchung, Fakturierung, Einrichtung, Berechtigungen und Anwenderdokumentation. Konkrete AL-Objekte bleiben bis zur Analyse offen.


# Referenced Business Context

# Business Context

## Company Goals

`GOAL-001` ist vorhanden, aber noch nicht fachlich beschrieben. Eine belastbare Nutzenzuordnung ist daher offen.

## Capabilities

- `CAP-SALES-001`: Auftraege abwickeln

## Processes and Business Cases

- `PROC-O2C-001`: Order-to-Cash
- `CASE-O2C-001`: Teil- und Nachlieferung

## Business Rules

- `BR-SALES-001`: Status Draft, Regelinhalt noch nicht freigegeben

## Roles and Stakeholders

Process Owner, Auftragsbearbeitung, Lager, Einkauf und Finanzbuchhaltung sind fachlich zu bestaetigen.

## Master Data and Documents

Potentiell betroffen: Debitor, Verkaufsauftrag, Verkaufslieferung und Verkaufsrechnung. Datenowner und Versandkostenquelle sind offen.

## Systems and Integrations

Business Central ist betroffen. Weitere Systeme sind im aktuellen Wissensstand nicht belegt.

## Project Scope

Der Change liegt innerhalb `PRJ-001`, dessen Scope noch vervollstaendigt werden muss.

## Knowledge Gaps and Assumptions

- BLOCKER: Gewuenschte Versandkostenregel nicht freigegeben.
- BLOCKER: Systemquelle des Versandkostenbetrags unbekannt.
- OFFEN: Behandlung von Gutschriften, Retouren und manuellen Abweichungen.
- OFFEN: Berechtigungen fuer Einrichtung und Ausnahmefreigabe.

## Source References

- `company/company-profile.md`
- `business/capability-map.md`
- `business/processes/order-to-cash.md`
- `business/business-cases/CASE-O2C-001-partial-delivery.md`
- `business/business-rules/BR-SALES-001-partial-delivery.md`
- `application-landscape/business-central/solution-overview.md`
- `projects/project-charter.md`
