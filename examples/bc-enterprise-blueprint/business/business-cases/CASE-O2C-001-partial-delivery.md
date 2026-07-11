# CASE-O2C-001: Teil- und Nachlieferung

Status: Beispielentwurf
Prozess: PROC-O2C-001

## Fachliches Ziel

Lieferbare Positionen koennen versendet werden, waehrend offene Restmengen nachvollziehbar bleiben.

## Ausloeser

Ein bestaetigter Auftrag ist nur teilweise lieferbar.

## Beteiligte Rollen

- Auftragsbearbeitung
- Lager
- Einkauf

## Normalablauf

1. Verfuegbarkeit pruefen.
2. Lieferbare Menge bereitstellen und buchen.
3. Restmenge offen halten.
4. Nach Wareneingang nachliefern.

## Varianten und Ausnahmen

- Kunde untersagt Teillieferungen.
- Artikel wird nicht wiederbeschafft.
- Versandkosten duerfen nur nach einer freigegebenen Regel berechnet werden.

## Betroffene Geschaeftsregeln

- BR-SALES-001

## BC-Bezug

Verkaufsauftrag, Lagerbeleg, gebuchte Verkaufslieferung und Verkaufsrechnung.

## Offene Fragen

- Welche Versandkostenregel ist fachlich freigegeben?
- Welche Rollen duerfen Ausnahmen bestaetigen?
