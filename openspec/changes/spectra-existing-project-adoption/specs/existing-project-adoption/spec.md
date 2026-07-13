# Existing Project Adoption Specification

## ADDED Requirements

### Requirement: Discovery ist read-only und revisionsgebunden

Spectra MUST vorhandene Jira- und Confluence-Strukturen aus einem portablen Export inspizieren, ohne die Quelle zu veraendern. Der Export MUST Site-/Projekt-/Board-/Space-Bindung, Quellrevision, Erfassungszeit und Digest enthalten.

#### Scenario: Drift vor Apply

- **WHEN** Revision, Digest oder ein referenziertes Quellobjekt nach der Planung abweicht
- **THEN** wird Apply ohne Schreibwirkung fail-closed abgelehnt

### Requirement: Mapping ist projektspezifisch

Spectra MUST beliebige beobachtete Issue-Typen, Hierarchieebenen, Status, Felder, Spaces und Root-Seiten explizit mappen koennen. Es MUST variable Kardinalitaet unterstuetzen und darf weder BC-Basic-Namen noch eine feste Jira-Struktur voraussetzen.

#### Scenario: Mehrdeutiges Mapping

- **WHEN** ein Quelltyp, Status oder Feld fehlt, unbekannt oder mehrfach fuehrend gemappt ist
- **THEN** wird die Konfiguration mit einem stabilen Fehlercode abgelehnt

### Requirement: Adoption erzeugt einen erklaerbaren Plan

Jede Planposition MUST genau eine Klasse `adopt-as-is`, `explicit-map` oder `improvement-proposal`, eine Quelle, ein Ziel, eine Begruendung und eine geplante Wirkung besitzen. Improvement-Proposals duerfen nie automatisch ausgefuehrt werden.

#### Scenario: Direkte Strukturmutation

- **WHEN** ein Plan eine ungefragte Remote-Erzeugung, Umbenennung, Umsortierung oder Loeschung vorsieht
- **THEN** wird er fail-closed abgelehnt

### Requirement: Apply ist kontrolliert und atomar

Lokales Apply MUST Plan-Digest, Discovery-Revision und explizite Bestaetigung pruefen und den Workspace atomar erzeugen. Remote-Apply MUST ohne spaeteren autorisierten Adapter blockiert bleiben.

#### Scenario: Apply ohne Bestaetigung

- **WHEN** Apply ohne passenden Plan-Digest oder explizite Bestaetigung aufgerufen wird
- **THEN** entstehen keine lokalen oder entfernten Writes

### Requirement: Konfiguration ist portabel und geheimnisfrei

Versionierte Dateien MUST sichere relative Pfade und Runtime-Secret-Schluessel statt Secretwerten verwenden. Absolute Pfade, Credentials, Tokens, Browserprofile und Kunden-Evidence sind unzulaessig.

#### Scenario: Secret oder absoluter Pfad

- **WHEN** eine Konfiguration ein Secret oder einen absoluten Laufzeitpfad enthaelt
- **THEN** wird sie fail-closed abgelehnt

### Requirement: Implementation und Support-only sind eigenstaendig belegbar

Ein Implementation-Profil MUST ein bestehendes Projekt mit Jira und Confluence uebernehmen koennen. Ein Support-only-Profil MUST ohne erfundenes Projekt und mit Supporttickets sowie Wissensspaces gueltig sein.

#### Scenario: Support-only ohne Projekt

- **WHEN** ein gueltiger Support-only-Export keine project_id besitzt
- **THEN** erzeugt Spectra einen lokalen Supportworkspace ohne ein Projekt zu erfinden
