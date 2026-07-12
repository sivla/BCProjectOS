# blueprint-catalog Specification

## Purpose
TBD - created by archiving change spectra-blueprint-catalog. Update Purpose after archive.
## Requirements
### Requirement: Spectra führt einen versionierten kuratierten Blueprint-Katalog
Spectra MUST wiederverwendbare Blueprint-Pakete und Blankovorlagen mit Zweck, Ablageort, Feldern, Referenzen und Inhaltsgrenze maschinenlesbar katalogisieren.

#### Scenario: Katalogvalidierung
- **WHEN** der Produktvertrag geprüft wird
- **THEN** existiert jede katalogisierte Vorlage, ist eindeutig, sicher relativ und als leere Vorlage markiert

### Requirement: Init erzeugt nur ausgewählte Strukturen
Spectra MUST passende Pakete empfehlen und MUST nur explizit ausgewählte Blueprint-Artefakte in den Zielworkspace kopieren.

#### Scenario: Schlanker Projektstart
- **WHEN** ein Projekt nur Confluence-Grundstruktur und Metadaten auswählt
- **THEN** werden keine Jira- oder zusätzlichen Blankodokumente erzeugt

### Requirement: Vorlagen behaupten keine Kundenwahrheit
Spectra MUST echte Kundenwerte, Secrets, simulierte Abnahmen und erfundene Evidence in Blankovorlagen verbieten.

#### Scenario: Unzulässiger Vorlageninhalt
- **WHEN** eine Vorlage reale oder als abgeschlossen behauptete Inhalte enthält
- **THEN** lehnt der Katalogvalidator den Produktstand fail-closed ab

