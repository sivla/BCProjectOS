# Design

`Test-PortableProjectStoryConformance.ps1 -Path <explicit-story-root>` liest ausschließlich den angegebenen Workspace. Der Workspace enthält `project-story.json` und relative Page-Dateien. Schema- und Fachvalidatoren arbeiten deterministisch, read-only und fail-closed.

Der Projektzeitraum kommt aus `offer.start_time`/`offer.end_time`. Timeline-Referenzen erlauben Ticket, Page, BC-Session, Evidence, Decision und Deliverable. Graphrelationen verwenden eine zentrale inverse Map.

Die Fixture wird aus einem temporären Fremdverzeichnis geprüft und enthält 3 Angebotsversionen, 19 Pages, 17 Tickets, 34 Kommentare, 17 Worklogs mit 80 Stunden und 9.600 EUR, 15 Timeline-Events und 3 Hypercaretage.

Die Kompatibilitätsprüfung 0.6 -> 0.7 ist explizit: additive Felder und neue Referenzdomänen sind zulässig; bestehende IDs, Statuswerte und Pflichtfelder bleiben unverändert; unbekannte oder nicht belegte Migrationen fail-closed.
