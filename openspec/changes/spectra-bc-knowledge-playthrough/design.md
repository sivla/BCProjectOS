# Design: BC-Wissen und Playthrough

## Architektur

Die technische Quellschicht nutzt eine Positivliste und exakte Commit-/Tree-/Lizenz-/Inhaltsdigests im externen `SPECTRA_KNOWLEDGE_ROOT`. Das Produkt speichert nur Registry, Schemas, Parser, Abfragevertrag und kleine synthetische Fixtures.

Darueber liegt ein kleiner fachlicher Startkatalog. Jede Aussage besitzt `knowledge_kind`, Version, Locale, Provenienz, Prozess-, Rollen-, Objekt-, Phasen- und Aufgabenreferenzen. Unbelegte Kurzbeschreibungen bleiben `unknown`.

Playthroughs sind read-only Plaene: Preconditions, Schritte, erwartete Wirkung, Readback, Evidence-Metadaten, Fehler- und Stop-Codes. Baseline, kundenspezifisches Soll und Readback bleiben getrennt. `CRONUS` ist nur `microsoft_demo_baseline`.

## Gezielte interne Kritik vor Umsetzung

- Ein grosser Objektindex waere ohne fachliche Tags fuer Consultants unbrauchbar; deshalb bleibt der Startkatalog kuratiert und klein.
- Dokumentations-URLs allein belegen keine getestete Ausfuehrung; daher sind `official_documented` und `tested_generic_procedure` getrennte Wahrheitsklassen.
- Ein Company-Copy-Plan kann technische Schritte beschreiben, darf aber keine Kundenkonfiguration oder erfolgreiche Ausfuehrung behaupten.
- Rolling `main`, lokale absolute Pfade und ungebundene Metadaten wuerden Reproduzierbarkeit brechen und werden fail-closed abgelehnt.
