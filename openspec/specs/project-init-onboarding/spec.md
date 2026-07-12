# project-init-onboarding Specification

## Purpose
TBD - created by archiving change spectra-project-init-onboarding. Update Purpose after archive.
## Requirements
### Requirement: Geführter Init besitzt drei sichere Einstiegspfade
Spectra MUST die Modi `new`, `local` und `onboard` deterministisch unterstützen und Dry-run als Standard verwenden.

#### Scenario: Neues Projekt planen
- **WHEN** eine gültige Init-Konfiguration ohne `-Apply` verarbeitet wird
- **THEN** wird ein maschinenlesbarer Plan ausgegeben und kein Ziel geschrieben

#### Scenario: Bestand aufnehmen
- **WHEN** `onboard` mit einem expliziten dateibasierten Export ausgeführt wird
- **THEN** liest Spectra die Quelle read-only, bindet Dateihashes und erzeugt ein Mappinginventar

### Requirement: Ein Projekt besitzt genau einen zentralen Projekt-Space
Spectra MUST genau einen `project_space` verlangen und MAY zusätzliche Bereiche ausschließlich als read-only Referenzen führen.

#### Scenario: Zentraler Space und Wissensreferenzen
- **WHEN** ein Projekt mit zusätzlichen Bereichen initialisiert wird
- **THEN** existiert genau ein zentraler Projekt-Space und jeder weitere Bereich ist `read_only`

### Requirement: Initialisierung ist fail-closed und atomar
Spectra MUST unsichere Pfade, unbekannte Prozesse, Secretmarker, Live-Endpunkte, vorhandene Ziele und unvollständige Onboardingquellen ablehnen und darf keinen Teilzustand als gültig hinterlassen.

#### Scenario: Unsichere Eingabe
- **WHEN** Pfad, Klassifikation, Ziel oder Exportvertrag ungültig ist
- **THEN** bricht Init mit stabilem Fehler ab und erzeugt keinen gültig behaupteten Zielworkspace

### Requirement: Atlassian-Strukturen bleiben portabel
Spectra MUST Confluence-Seitenbaum und Ticketstruktur als dateibasierten Vertrag erzeugen und MUST projektspezifische Vorgangstypen und Status über ein versioniertes Mapping auf ein stabiles kanonisches Kernmodell abbilden.

#### Scenario: Portabler Kollaborationsvertrag
- **WHEN** `portable-atlassian` gewählt wird
- **THEN** erzeugt Spectra lokale Seiten- und Vorgangsstrukturen mit deaktiviertem Live-Schreibzugriff

#### Scenario: Neues Projekt mit Standardprofil
- **WHEN** ein neues Projekt `spectra-standard` auswählt
- **THEN** wird eine schlanke empfohlene Ticketstruktur als austauschbares Profil erzeugt

#### Scenario: Bestehendes Projekt mit eigener Struktur
- **WHEN** ein read-only Export projektspezifische Vorgangstypen enthält
- **THEN** bleibt jeder Quellwert erhalten und besitzt genau eine explizite Spectra-Abbildung

#### Scenario: Unbekannter Vorgangstyp
- **WHEN** ein Export einen nicht abgebildeten Vorgangstyp enthält
- **THEN** bricht das Onboarding fail-closed ab und verlangt eine Mappingentscheidung

### Requirement: Fachliche Projektart ist vom Workspaceprofil getrennt
Spectra MUST `implementation`, `support`, `fit-gap` und `migration` als versionierte Projektarten führen und jede Projektart genau einem unterstützten technischen Profil zuordnen.

#### Scenario: Fit-Gap-Projekt
- **WHEN** ein Operator ein Fit-Gap initialisiert
- **THEN** verwendet Spectra den Implementation-Produktkern, kennzeichnet den Auftrag jedoch eindeutig als `fit-gap`

#### Scenario: Support-Onboarding
- **WHEN** ein Operator ein Supportprojekt initialisiert
- **THEN** verwendet Spectra das Profil `support-only` und empfiehlt ausschließlich die schlanke Supportstruktur

### Requirement: Blueprintempfehlungen bleiben explizit
Spectra MUST je Projektart einen kuratierten Blueprintsatz empfehlen, aber ausschließlich explizit ausgewählte Pakete erzeugen.

#### Scenario: Schlankes Supportprojekt
- **WHEN** die Projektart `support` gewählt ist
- **THEN** werden Consulting-Blankovorlagen nicht automatisch erzeugt

### Requirement: Projektübergänge sind read-only referenziert
Spectra MUST eine optionale Vorgängerbeziehung nur mit stabiler Projekt-ID, erlaubter Projektart, katalogisierter Beziehung und `read_only=true` akzeptieren.

#### Scenario: Fit-Gap wird Implementation
- **WHEN** eine Implementation einen Fit-Gap als Vorgänger mit `continues-as` referenziert
- **THEN** persistiert Spectra die Herkunft ohne Vorgängerinhalt zu kopieren oder zu verändern

#### Scenario: Unerlaubter Übergang
- **WHEN** Projektart, Profil, Beziehung oder Vorgängertyp nicht zum Katalog passen
- **THEN** lehnt Init mit einem stabilen Fehlercode ab

