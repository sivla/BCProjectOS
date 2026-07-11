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
