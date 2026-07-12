# Geführte Spectra-Projektinitialisierung

Spectra unterstützt drei portable Einstiege: `new` für ein neues BC-Basic-Projekt, `local` für einen rein lokalen Workspace und `onboard` für die read-only Bestandsaufnahme eines dateibasierten Exports.

Jeder Projektworkspace besitzt genau einen zentralen Projekt-Space. Weitere Confluence-kompatible Bereiche sind ausschließlich lesende Referenzen. Die Jira-kompatible Arbeitsstruktur und der Seitenbaum sind lokale Verträge; Live-Zugänge, Tokens, Site-URLs und Schreibsynchronisation gehören nicht zu diesem Vertrag.

Der Init-Vertrag erfasst nur Informationen, die Vertrieb, PM und Beratung für Projektstart und Übergabe benötigen: Projektkennung, Profil, Sprache, BC-Basic-Prozesse, Kollaborationsmodus, zentralen Projekt-Space und optionale Wissensreferenzen. Dry-run ist Standard. Apply schreibt atomar in ein leeres Ziel.

Beim Onboarding bleiben Quelldateien unverändert. Spectra bindet Pfad, SHA-256 und Datensatzanzahl und erzeugt daraus ein lokales Inventar. Fachliche Bestandsinhalte bleiben Eigentum des erzeugten Workspaces und werden niemals Bestandteil des Spectra-Produktpayloads.

## Ticketarchitektur

Spectra besitzt keine verpflichtende Jira-Vorgangstyp- oder Workflowkonfiguration. Das Produkt definiert nur kanonische fachliche Kategorien und Status. Jedes Projekt führt einen versionierten Mappingvertrag von seinen eigenen Vorgangstypen, Hierarchien und Status auf dieses Kernmodell.

Das Profil `spectra-standard` ist eine optionale Startvorlage für neue Projekte. Bestehende Jira- oder andere Ticketsysteme verwenden `project-mapping` beziehungsweise `imported-readonly`. Quellbegriffe bleiben erhalten. Unbekannte oder doppelt abgebildete Typen und Status werden fail-closed behandelt und benötigen eine explizite Projektentscheidung.
