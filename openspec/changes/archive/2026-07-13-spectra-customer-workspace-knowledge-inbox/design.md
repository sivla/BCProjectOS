# Design

Der Kundenworkspace enthält genau eine Kundenidentität und getrennte Arrays für Umgebungen, Gesellschaften, Projekte, Supportfälle, Wissenseinträge, Budgets, Verpflichtungen und typisierte Relationen. Ein Support-only-Kunde ohne Projekt ist ausdrücklich gültig. Alle fachlichen Scopes verweisen auf stabile IDs; der Validator löst jede Referenz fail-closed auf.

Die Knowledge Inbox liegt neben dem kanonischen Workspacezustand. Intake-Dateien werden nur über sichere relative Pfade, SHA-256 und Quellrevision referenziert. Observations beschreiben ausschließlich belegte Aussagen. ComparisonRuns binden den aktuellen Workspace-Digest. Proposals enthalten erwarteten Digest und vorgeschlagene Operation, verändern den Zielzustand aber nicht. ReviewDecisions sind menschliche Entscheidungen; auch eine Annahme erzeugt in diesem Block noch keinen Apply-Plan.

Generator und Validator arbeiten offline und deterministisch. Die positive Fixture enthält ein Implementation-Profil mit Projekt sowie ein Support-only-Profil ohne Projekt. Die Negativmatrix isoliert Kunden-/Scopefehler, doppelte Revisionen, Manipulation, Stale-Zustände, unbekannte Referenzen, automatische Writes und Secret-/Kundenmarker.
