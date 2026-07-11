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
