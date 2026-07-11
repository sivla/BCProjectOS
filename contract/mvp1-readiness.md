# MVP-1-Readiness

Status: ARCHITECTURE_READY; POV_DECISION_REDUCE; MVP1_START_AUTHORIZED

MVP 1 ist architektonisch bereit, weil folgende Grundsatzentscheidungen verbindlich getroffen sind:

- Spectra-Produktgrenze und externe Systemgrenzen; das technische Repository bleibt BCProjectOS;
- ein physisch isolierter Kundenworkspace als oberste Einheit;
- genau ein OpenSpec-Root pro Kundenworkspace;
- kanonische Entitaeten, Speicherorte, stabile IDs und gerichtete Relationen;
- Trennung von Pfad, ID, Tag, Status und externem Schluessel;
- Source-of-Truth-Regeln und Datenklassen;
- kontrollierte Dokumenttypen, Tags und Statusachsen;
- fail-closed Umgang mit unbekannten und unsicheren Dateien;
- Datenschutz und Kundentrennung;
- Speicherung grosser Binaerdateien, SHA-256, Duplikate und Originalschutz;
- Backup-, Restore-, Retention- und Loeschvertrag ohne erfundene Betriebswerte;
- Semantic Versioning und explizite Migrationen;
- Kriterien fuer OpenSpec-Promotion;
- lokale, read-only Vertragsvalidierung.

## Verbindliche Eingaben fuer MVP 1

Der Generator muss die in `workspace-architecture.md` festgelegte High-Level-Struktur erzeugen, `workspace.yaml` gegen das Schema schreiben, kontrollierte Kataloge uebernehmen, leere Profile ohne Scheindaten zulassen und die Blueprint-Version erfassen.

## Gate-Status

| Gate | Status | Begruendung |
|---|---|---|
| MVP-0-Architekturvertrag | PASS | Entscheidungen, Kataloge, Schemas und lokale Validierung liegen vor. |
| Offene Grundsatzentscheidung | PASS | Keine Architekturentscheidung blockiert den Blank-Workspace. |
| Proof of Value | PASS | POV-001 ist synthetisch und lokal validiert; die Grenzen der Aussagekraft bleiben dokumentiert. |
| Nutzerentscheidung | PASS | Der Nutzer hat am 2026-07-11 `Reduce` explizit freigegeben. |
| Start MVP 1 insgesamt | IN_PROGRESS | Der reduzierte MVP-1-Umfang laeuft; eine nicht installierbare synthetische Teilimplementierung und Consumer-Bindungsvalidierung existieren, der installierbare Workspace bleibt gesperrt. |

## Keine offenen Architekturentscheidungen

Fuer MVP 1 besteht keine offene Grundsatzentscheidung. Betriebsspezifische Werte wie RPO, RTO, Aufbewahrungsfristen, Freigaberollen und Speicherziel sind bewusst Konfiguration eines realen Kundenworkspace und blockieren den synthetischen Blank-Workspace nicht. Das separate Proof-of-Value-Gate wurde durch die Nutzerentscheidung `Reduce` aufgeloest.

## Verbindlicher Reduce-Rahmen

Die Freigabe gilt nur fuer den schlanken Blank-Workspace und die rudimentaere BC-Baseline aus MVP 1. Pflichtmetadaten und erzeugte Ausgaben bleiben minimal; ungenutzte Profile bleiben leer. MVP 2 und spaeter, produktive Dateiverarbeitung, der volle Delivery-Ausgabebaum, Project Twin, UI und externe Systeme sind nicht mitfreigegeben.

## Bewusst spaeter

Inbox-Verarbeitung, OCR, Klassifikationsschwellen, UI, Datenbank, Git LFS/Object Storage, externe Synchronisation, mehrere OpenSpec-Roots sowie die Einordnung des Delivery-Spikes werden in den dafuer vorgesehenen spaeteren MVPs entschieden oder umgesetzt.

## Aufgeloeste MVP-1-Vertragsentscheidungen

- Das finale installierbare Release-Manifest folgt `schemas/release-manifest.schema.json`; der annotierte Tag-Commit bleibt die extern aufgeloeste Release-Bindung und wird nicht zirkulaer in sein eigenes Manifest geschrieben.
- Synthetische Vorab-Fixtures folgen `schemas/synthetic-workspace-fixture.schema.json`, enthalten kein `workspace.yaml` und keine erfundene Produktversion. Sie sind keine Kundenworkspaces und koennen die installierbare Workspace-Pruefung nicht bestehen.
- Die historische synthetische Vertrags- und POV-Evidence bleibt unveraendert als nicht bindbare historische Evidence klassifiziert; sie ist weder Vorab-Fixture noch Release-Eingabe.
- Consumer-Bindungen folgen `schemas/consumer-binding.schema.json`: Ohne vollstaendige externe Tag-, Commit-, finales-Manifest- und Digest-Pruefung bleibt nur `PENDING_BCPROJECTOS_RELEASE` zulaessig.
