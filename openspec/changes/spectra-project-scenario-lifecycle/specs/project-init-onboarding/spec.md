# Projektarten und Übergänge

## ADDED Requirements

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
