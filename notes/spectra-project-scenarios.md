# Projektarten für einen schlanken BC-Projektstart

Spectra trennt die technische Workspaceform von der fachlichen Projektart. Dadurch bleibt der Produktkern stabil, während Vertrieb, Projektleitung und Beratung den tatsächlichen Auftrag klar benennen.

| Projektart | Workspaceprofil | Typischer Einstieg | Empfohlene Ausgangsstruktur |
|---|---|---|---|
| `fit-gap` | `implementation` | Discovery und Fit-to-Standard | Projektbereich, Jira, Blankovorlagen und Metadaten |
| `implementation` | `implementation` | vollständige BC-Einführung | Projektbereich, Jira, Blankovorlagen und Metadaten |
| `migration` | `implementation` | Ablösung eines Vorsystems | Projektbereich, Jira, Blankovorlagen und Metadaten |
| `support` | `support-only` | Übernahme oder laufende Betreuung | Projektbereich, Jira und Metadaten |

Nur explizit gewählte Blueprints werden erzeugt. Eine Empfehlung ist keine automatische Projektentscheidung.

## Übergänge

Ein Fit-Gap kann mit `continues-as` als Vorgänger einer Implementation referenziert werden. Eine Migration kann mit `migrates-from` auf ein Fit-Gap oder eine Implementation verweisen. Support kann mit `onboards-from` eine Implementation, Migration oder einen vorherigen Supportstand referenzieren.

Die Vorgängerbeziehung enthält nur stabile Projekt-ID, Projektart und Beziehung. Sie ist immer read-only. Spectra kopiert keine Vorgänger- oder Kundeninhalte und verändert kein anderes Projekt.

## Geführte Initialisierung

Der Antwortenvertrag ergänzt `project_type` sowie optional:

- `predecessor_project_id`
- `predecessor_project_type`
- `predecessor_relationship`

Die drei Vorgängerfelder werden nur vollständig gemeinsam akzeptiert. Der erzeugte Projektvertrag hält Projektart, ausgewählte und empfohlene Blueprints sowie die optionale read-only Herkunft nachvollziehbar fest.
