# Business-Central-Referenzbibliothek

## Purpose

Dieser Vertrag bindet die lokale Business-Central-Referenzbibliothek an positivgelistete, unveraenderliche Quellen und einen deterministischen, versionsbezogenen Offline-Index.

## Requirements

### Requirement: Quellen sind positivgelistet und unveränderlich gebunden
Spectra MUST jede Quelle an kanonische URL, Rolle, exakten Commit, Tree, Lizenzblob und Inhaltsdigest binden.

#### Scenario: Ungepinnte Quelle
- **WHEN** eine Quelle keinen exakten Commit, Tree, Lizenz- oder Inhaltsdigest besitzt
- **THEN** wird sie fail-closed abgelehnt

### Requirement: Cache bleibt außerhalb aller Projektworkspaces
Spectra MUST Bare-Mirrors ausschließlich unter einem sicheren `SPECTRA_KNOWLEDGE_ROOT` lesen oder explizit aktualisieren.

#### Scenario: Unsicherer Cachepfad
- **WHEN** ein Mirrorpfad den sicheren Runtime-Root verlaesst oder einen Reparse-Escape enthaelt
- **THEN** wird der Zugriff fail-closed abgelehnt

### Requirement: Objektkatalog ist versions- und lokalisierungsbezogen
Spectra MUST Objektkeys aus App, Country, Typ und ID bilden und BC-Version, installierte Appversion, Quelle und Provenienz erhalten.

#### Scenario: Mehrdeutiger Objektkey
- **WHEN** zwei Objekte denselben App-Country-Typ-ID-Key beanspruchen
- **THEN** wird der Indexaufbau als mehrdeutig abgelehnt

### Requirement: Fachliche Beschreibung wird nicht erfunden
Spectra MUST unbelegte Zwecke als `unknown` kennzeichnen und belegte Texte an offizielle oder kuratierte Provenienz binden.

#### Scenario: Unbelegte Beschreibung
- **WHEN** fuer ein Objekt keine belegte fachliche Beschreibung vorliegt
- **THEN** bleibt sein Zweck sichtbar `unknown`

### Requirement: Build und Query bleiben deterministisch offline
Spectra MUST aus einem validierten Lock byteidentische Indexe erzeugen und Query ohne validierten Snapshot ablehnen.

#### Scenario: Wiederholter Build
- **WHEN** derselbe validierte Lock zweimal indexiert wird
- **THEN** sind die Indexartefakte byteidentisch
