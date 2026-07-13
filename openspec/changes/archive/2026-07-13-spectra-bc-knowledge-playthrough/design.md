# Design: BC-Wissen und Playthrough

## Architektur

Die technische Quellschicht nutzt eine Positivliste und exakte Commit-/Tree-/Lizenz-/Inhaltsdigests im externen `SPECTRA_KNOWLEDGE_ROOT`. Das Produkt speichert nur Registry, Schemas, Parser, Abfragevertrag und kleine synthetische Fixtures.

Diese Quellschicht ist ein expliziter Foundation-Import aus dem vollstaendigen Commit `dff88684d062e23794cbfb5423aecd331ac49790`. Dieser Commit ist kein Vorfahr des aktuellen Branches; gemeinsamer Merge-Base ist RC.1 `0c4542f8e69c3a7d52807b96b9bdd50a54309371`. Ein Importmanifest bindet jede uebernommene Datei an den originalen Git-Blob. Die spaetere Integration mit der RC2/RC3-Linie bleibt ein eigenes kontrolliertes Vorhaben.

Darueber liegt ein kleiner fachlicher Startkatalog. Jede Aussage besitzt `knowledge_kind`, Version, Locale, Provenienz, Prozess-, Rollen-, Objekt-, Phasen- und Aufgabenreferenzen. Unbelegte Kurzbeschreibungen bleiben `unknown`.

Playthroughs sind read-only Plaene: Preconditions, Schritte, erwartete Wirkung, Readback, Evidence-Metadaten, Fehler- und Stop-Codes. Baseline, kundenspezifisches Soll und Readback bleiben getrennt. `CRONUS` ist nur `microsoft_demo_baseline`.

## Gezielte interne Kritik vor Umsetzung

- Ein grosser Objektindex waere ohne fachliche Tags fuer Consultants unbrauchbar; deshalb bleibt der Startkatalog kuratiert und klein.
- Dokumentations-URLs allein belegen keine getestete Ausfuehrung; daher sind `official_documented` und `tested_generic_procedure` getrennte Wahrheitsklassen.
- Ein Company-Copy-Plan kann technische Schritte beschreiben, darf aber keine Kundenkonfiguration oder erfolgreiche Ausfuehrung behaupten.
- Rolling `main`, lokale absolute Pfade und ungebundene Metadaten wuerden Reproduzierbarkeit brechen und werden fail-closed abgelehnt.
