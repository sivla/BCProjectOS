# Business-Central-Referenzbibliothek

## ADDED Requirements

### Requirement: Quellen sind positivgelistet und unveränderlich gebunden
Spectra MUST jede Quelle an kanonische URL, Rolle, exakten Commit, Tree, Lizenzblob und Inhaltsdigest binden.

#### Scenario: Floating Branch
- **WHEN** ein Lock nur `main` oder keinen vollständigen Commit enthält
- **THEN** ist der Snapshot nicht queryfähig

### Requirement: Cache bleibt außerhalb aller Projektworkspaces
Spectra MUST Bare-Mirrors ausschließlich unter einem sicheren `SPECTRA_KNOWLEDGE_ROOT` lesen oder explizit aktualisieren.

#### Scenario: Unsicherer Cachepfad
- **WHEN** der Cache in Produkt- oder Kundenrepo zeigt oder über Symlink entkommt
- **THEN** stoppt der Vorgang fail-closed

### Requirement: Objektkatalog ist versions- und lokalisierungsbezogen
Spectra MUST Objektkeys aus App, Country, Typ und ID bilden und BC-Version, installierte Appversion, Quelle und Provenienz erhalten.

#### Scenario: W1- und DE-Objekt
- **WHEN** dieselbe Objekt-ID in W1 und DE vorkommt
- **THEN** bleiben beide Einträge getrennt und suchbar

### Requirement: Fachliche Beschreibung wird nicht erfunden
Spectra MUST unbelegte Zwecke als `unknown` kennzeichnen und belegte Texte an offizielle oder kuratierte Provenienz binden.

#### Scenario: Unbelegte Beschreibung
- **WHEN** ein Parser keine belastbare Dokumentquelle findet
- **THEN** lautet der Zweckstatus `unknown` ohne generierten Erklärungstext

### Requirement: Build und Query bleiben deterministisch offline
Spectra MUST aus einem validierten Lock byteidentische Indexe erzeugen und Query ohne validierten Snapshot oder bei stiller Sourcemutation ablehnen.

#### Scenario: Wiederholter Build
- **WHEN** derselbe Lock zweimal gebaut wird
- **THEN** sind Manifest- und Indexdigests identisch
