# POV-001 Workflow-Auswertung

Status: Completed Synthetic Run - Decision Reduce

Es existiert keine belastbare manuelle Baseline. Die folgenden Stunden sind ausschliesslich die im synthetischen Pilotledger konsistent gefuehrten Aufwandswerte; daraus wird keine Zeitersparnis abgeleitet. Der reproduzierbare Automationslauf dauerte in der beobachteten lokalen Ausfuehrung nur wenige Sekunden, ist aber nicht mit menschlicher Arbeitszeit vergleichbar.

| Workflow | Setup | Verarbeitung | Review/Nacharbeit | Korrekturen | Wiederauffindbarkeit | Praktisch nutzbar | Waste | Vertrauensrisiko |
|---|---:|---:|---:|---|---|---|---|---|
| Externe Dateien | 0.5 h | 1.0 h | 0.5 h | Unbekannte Datei bewusst nicht korrigiert, sondern in Review gehalten | Register-ID -> Hashblob -> Kontext-IDs ist lokal pruefbar | Originalschutz, Hash, Register, Routinglog | Vier Tag-Dimensionen sind ausreichend; keine Erweiterung noetig | Automatische Typannahme bei unbekannten Dateien; fail-closed abgefangen |
| Meeting | 0.5 h | 1.0 h | 1.0 h | Keine fachliche Korrektur behauptet; Human Review steht aus | Meeting-ID verbindet Transcript, Support, Projekt und Kandidaten | Vorbereitung, Agenda, Draft-Protokoll, Fragen und Risiken | Einzelne Kandidaten sollten spaeter strukturiert werden, im PoV reicht ein Dokument | Entwuerfe koennten als Beschluss gelesen werden; mehrfach als Draft markiert |
| Supportfall | 0.25 h | 0.75 h | 0.5 h | Routingentscheidung dokumentiert, nicht als allgemeine Regel behandelt | Support-ID verbindet Projekt, Meeting, Dateien, Evidence und Change | Prioritaetsbegruendung und Promotionentscheidung | Ein einfacher Direktloesungsfall wurde nicht zusaetzlich erfunden | Zu fruehe Promotion; durch explizite Kriterien begrenzt |
| Projekt/Budget | 0.25 h | 0.25 h | 0.0 h | Summen maschinell geprueft | Projekt-ID und Arbeitspakete sind direkt auffindbar | Plan/Ist/Rest/Forecast inklusive Meetingaufwand | Kein Kosten- oder Rechnungsmodell erforderlich | Synthetische Stunden duerfen nicht als echte Baseline gelesen werden |
| Governed Change | 0.5 h | 0.5 h | 0.5 h | Businessregel, Accounting und Design bleiben absichtlich blockiert | Change -> Requirement -> Regel sowie Support/Meeting/Projekt sind ID-verknuepft | Planning, Ticketmanifest, UAT-Entwurf, Dokumentation, Release-Entwurf und Gatebericht | Spike erzeugt 39 Dateien; Pilot uebernimmt nur 6 benoetigte Dateien | Generierte Drafts koennten Erledigung suggerieren; Gates und Evidence blockieren |

Gesamtes synthetisches Ledger: 8.0 h Plan, 8.0 h Ist, 0.0 h Rest, 8.0 h Forecast. Dies ist weder Abrechnung noch gemessene Produktivitaetsbaseline.

## Retain

- stabile IDs und gerichtete Relationen;
- SHA-256-Originalschutz und ein Register je Intake-Vorgang;
- Dokumenttyp plus die bestehenden vier Tag-Dimensionen;
- Draft-/Review-Grenze fuer Meeting, Wissen und Tickets;
- explizite Promotionentscheidung;
- Planning/BuildReady/ReleaseReady als getrennte fail-closed Gates;
- kleiner Projektaufwand mit Meetingvorbereitung und Nachbereitung.

## Remove from the retained pilot default

- keine neuen Tags oder universellen Metadatenfelder;
- keine zweite Kopie kanonischer Support-, Meeting- oder Change-Inhalte;
- keine Confluence- und Trainingskopie fuer diesen Pilotfall;
- keine pauschale OpenSpec-Promotion fuer einfache Supportfragen.

## Deferred

- produktive Intake-Automation, MIME-Erkennung und Konfidenzschwellen;
- strukturierte Einzelentitaeten fuer Decisions und Actions;
- echte manuelle Baseline und erneute Nutzung durch den Anwender;
- Git LFS/Object Storage, OCR, UI, API und externe Synchronisation;
- Project-Twin-Snapshot oder Repository-Aenderung.

## Nutzwert und Grenzen

Der Pilot ist ohne Chathistorie aus Dateien und IDs rekonstruierbar. Originalschutz, Meetingnachbereitung, Support-Promotion und Gatebericht sind praktisch verwertbar. Noch unbewiesen sind reale Zeitersparnis, freiwillige Wiederverwendung und der Reviewaufwand bei echten Unterlagen. Diese Punkte verhindern eine vorbehaltlose Go-Empfehlung.

## Produktentscheidung

Der Nutzer hat am 2026-07-11 `Reduce` explizit freigegeben. Der technische PoV bleibt unveraendert bewertet; die Entscheidung erlaubt ausschliesslich den reduzierten MVP-1-Umfang und ist keine Freigabe fuer produktive Intake-Automation, spaetere MVPs oder Plattformarbeit.
