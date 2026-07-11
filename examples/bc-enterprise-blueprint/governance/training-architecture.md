# Training Architecture

Schulungen werden aus freigegebenen Geschaeftsprozessen, Anforderungen, BC-Verhalten und UAT-Szenarien abgeleitet. Eine generierte Unterlage ist ein Entwurf und kein Nachweis fuer eine durchgefuehrte Schulung.

## Schulungszweck

Jede Schulung muss beantworten:

- Welche betriebliche Veraenderung wird eingefuehrt?
- Welche Zielgruppe muss danach was sicher ausfuehren koennen?
- Welche Fehler oder Risiken soll die Schulung vermeiden?
- Welche Voraussetzungen und Berechtigungen sind notwendig?
- Wie wird der Lernerfolg nachgewiesen?

## Schulungsebenen

| Typ | Zielgruppe | Schwerpunkt |
|---|---|---|
| Prozessschulung | Fachanwender und Key User | End-to-End-Prozess, Varianten und Regeln |
| Anwendungsschulung | Operative BC-Benutzer | Masken, Belege, Aktionen und Fehlerbehandlung |
| Key-User-Schulung | Multiplikatoren und Tester | Prozess, Einrichtung, UAT und First-Level-Support |
| Admin-Schulung | BC-Administration | Einrichtung, Berechtigungen, Monitoring und Support |
| Entwickler-Schulung | AL-Entwicklung | Architektur, Events, Tests, Upgrade und Debugging |
| Betriebsuebergabe | Betrieb und Support | Deployment, Runbooks, Diagnose und Eskalation |

## Pflichtbestandteile

1. Schulungssteckbrief mit Zweck, Zielgruppe, Dauer, Format und Owner.
2. Messbare Lernziele mit stabilen IDs `LEARN-*`.
3. Voraussetzungen, Rollen und benoetigte Umgebung.
4. Agenda und Inhaltsmodule.
5. Trainerleitfaden mit Hinweisen und erwarteten Fragen.
6. Teilnehmerunterlagen mit Prozess- und Bedienablauf.
7. Praktische Uebungen mit synthetischen Daten.
8. Wissenscheck oder praktische Erfolgskontrolle.
9. Feedback- und offene-Punkte-Protokoll.
10. Durchfuehrungs- und Freigabestatus ohne erfundene Ergebnisse.

## OpenSpec-Mapping

| Quelle | Schulungsergebnis |
|---|---|
| Business Context | Zielgruppen, Rollen und betrieblicher Zweck |
| Requirements | Lernziele und erwartetes Systemverhalten |
| Scenarios | Demonstrationen, Uebungen und Wissenscheck |
| Design | Admin-, Entwickler- und Betriebsmodule |
| UAT | Realistische End-to-End-Uebungen |
| Documentation | Teilnehmerunterlagen und Nachschlagewerk |
| Release | Gueltigkeit, Version und Einfuehrungszeitpunkt |

## Lokale Ablage

```text
deliverables/<change-id>/training/
|-- training-brief.md
|-- agenda.md
|-- trainer-guide.md
|-- participant-guide.md
|-- exercises.md
|-- knowledge-check.md
|-- feedback-template.md
|-- attendance-template.md
`-- training-manifest.json
```

## Schutzregeln

- Nur synthetische oder freigegebene anonymisierte Schulungsdaten verwenden.
- Keine Teilnehmernamen oder Anwesenheitsdaten in OpenSpec ablegen.
- Keine Schulung als durchgefuehrt oder bestanden markieren, solange kein Nachweis existiert.
- Screenshots und Bedienhinweise muessen zur freigegebenen BC-Version passen.
- Lernziele muessen auf Anforderungen, Prozesse oder Geschaeftsregeln zurueckfuehrbar sein.
