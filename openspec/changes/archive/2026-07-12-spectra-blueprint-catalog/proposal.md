# Change: Kuratierter Blueprint- und Blankovorlagenkatalog

## Why
Neue BC-Projekte benötigen eine einheitliche, schlanke Ausgangsstruktur, ohne dass Spectra Kundendaten oder künstliche Projektstände vorgibt. Bisher existiert kein versionierter Katalog, aus dem `spectra init` genau passende Strukturen auswählen kann.

## What Changes
- Versionierter, maschinenlesbarer Blueprint-Katalog.
- Projekt-Confluence-Blueprint mit `00 Support`, `01 Unternehmen`, `02 Business Central`, `03 Projekte`, `04 Handbücher` und `99 Archiv`.
- Ehrlich leere Blankovorlagen für die zentralen Consulting- und Betriebsartefakte.
- Jira-Projekt-Blueprint `Phase -> Epic -> Story -> Task`, ausschließlich Task als abrechenbare Arbeitseinheit.
- Dokument-, Referenz- und Snapshot-Metadatenvorlagen.
- Explizite Auswahl und profilabhängige Empfehlung in `spectra init`.

## Nicht-Scope
- Keine Live-Atlassian-/Rovo-Verbindung.
- Keine Kundenwerte, Secrets, echte Abnahmen oder Evidence.
- Keine automatische Übernahme aus Kundenprojekten.
- Keine Release- oder Versionsbehauptung außerhalb des Katalogvertrags.
