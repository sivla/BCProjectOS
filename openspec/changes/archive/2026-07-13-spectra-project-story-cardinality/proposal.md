# Proposal: Variable Projektstory-Kardinalität und Hierarchie

## Ziel

Der generische Project-Story-Vertrag soll beliebig viele fachlich abgeleitete Pages, Tickets, Timeline-Ereignisse und Hypercaretage unterstützen. Eine Anzahl aus einer synthetischen Fixture, ein Kunden-Nummernkreis oder ein impliziter Schwellenwert darf niemals Produktparameter sein.

## Scope

- variable Kardinalität für alle wiederholbaren Storysammlungen;
- stabile, domänenbezogene ID-Eindeutigkeit;
- optionale Parent-/Epic-/Abhängigkeitsbeziehungen mit vollständiger Hierarchieprüfung;
- leere Sammlungen nur dort, wo das Profil sie erlaubt;
- Negativfälle für feste Count-Annahmen, doppelte IDs, Waisen, Zyklen und unzulässige Referenzen.

## Nicht-Scope

- keine Kundeninhalte, Ticketnummernkreise oder Atlassian-Livezugriffe;
- keine Änderung von RC.2/RC.3-Candidates;
- keine neuen Fachprozesse, Screens oder Releasepromotion;
- keine künstliche Mindestanzahl zur Simulation von Vollständigkeit.

## Abnahme

Eine positive Fixture mit zwei und eine mit mehr als zwanzig Tickets müssen denselben Vertrag erfüllen, sofern Referenzen, Status und Profilregeln gültig sind. Eine leere Sammlung wird nur bei explizit erlaubtem Profilzustand akzeptiert. Jeder Fehler wird mit stabilem Code und ohne Reparatur gemeldet.
