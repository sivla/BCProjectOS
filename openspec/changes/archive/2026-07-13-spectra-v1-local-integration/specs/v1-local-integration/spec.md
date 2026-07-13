# v1-local-integration Specification

## Purpose

Dieser Vertrag beschreibt die lokale Konsolidierung zweier belegter Spectra-V1-Vertragslinien und den danach getrennt erzeugten, nicht installierbaren `1.0.0`-Candidate. Er fuehrt keine neue Produktfunktion und keine Published-Behauptung ein.

## ADDED Requirements

### Requirement: Beide Quellhistorien bleiben unveraendert nachvollziehbar

Der Integrationsstand MUST die P0-Linie und die Knowledge-Playthrough-Linie ueber einen normalen Merge mit RC.1 als gemeinsamer Basis enthalten. Quellbranches duerfen nicht umgeschrieben werden.

#### Scenario: Integrationsgraph

- **WHEN** der Integrationscommit geprueft wird
- **THEN** sind beide dokumentierten Source-Commits Vorfahren und der dokumentierte Merge-Base stimmt exakt

### Requirement: Jede Konfliktdomaene besitzt genau einen fuehrenden Vertrag

Inbox-Verarbeitung, Blueprint-Vorschau und BC-Wissensfoundation MUST jeweils genau einen fuehrenden Vertrag besitzen. Kompatibilitaetspfade duerfen die fuehrende Wahrheit weder duplizieren noch umgehen. Legacy-Blankoartefakte duerfen nur ueber eine eindeutige V2-Zuordnung als nicht fuehrende Kompatibilitaetsprojektion ausgegeben werden.

#### Scenario: Parallele Inbox-Statusmaschine

- **WHEN** ein Kompatibilitaetspfad eine direkte Zielmutation oder eine zweite Proposal-Statusmaschine einfuehrt
- **THEN** lehnt das Integrationsgate den Stand fail-closed ab

#### Scenario: Parallele Blueprint-Wahrheit

- **WHEN** eine neue Vorschau den Legacy-Katalog statt des V2-Vertrags als fuehrende Quelle verwendet
- **THEN** lehnt das Integrationsgate den Stand fail-closed ab

#### Scenario: Doppelte Wissensfoundation

- **WHEN** Foundation-Blobs abweichen oder eine zweite ungepinnte Registry oder Cachelogik entsteht
- **THEN** lehnt das Integrationsgate den Stand fail-closed ab

### Requirement: P0-Skills respektieren integrierte Guardrails

P0-Skills MUST Proposal-only-Intake, V2-Blueprint-Vorschau, gepinnte Wissensquellen und die CRONUS-Wahrheitsgrenze respektieren. Sie MUST direkte Kundenmutation und ungepinnte Wissensnutzung ablehnen.

#### Scenario: Unsicherer Skillpfad

- **WHEN** ein Skill direkte Kundenmutation, eine floating Wissensquelle oder CRONUS als kundfertig erlaubt
- **THEN** schlaegt das Integrationsgate mit einem stabilen Befund fehl

### Requirement: Project-Story-Kardinalitaet ist instanzabgeleitet

Portable Project Stories MUST variable Seiten-, Ticket-, Timeline- und Hypercare-Mengen aus der validierten Instanz ableiten. Feste synthetische Mengen oder Kunden-ID-Ranges sind unzulaessig.

#### Scenario: Abweichende gueltige Mengen

- **WHEN** eine synthetische gueltige Story andere Mengen als Referenzfixtures besitzt
- **THEN** wird sie anhand ihrer Relationen und Inhalte statt anhand fester Counts validiert

### Requirement: Lokaler Candidate ist kein Release

Der Integrationsstand und sein lokaler `1.0.0`-Candidate MUST `PENDING_BCPROJECTOS_RELEASE` bleiben. Der Candidate MUST nicht installierbar und `CONTRACT_REFERENCE_ONLY` sein und MUST weder finales Manifest, Tag- noch Published-Evidence erzeugen.

#### Scenario: Unzulaessiger finaler Releaseclaim

- **WHEN** der Integrationsdelta ein finales, installierbares, getaggtes oder veroeffentlichtes `1.0.0` behauptet
- **THEN** wird die Uebergabe als NO-GO bewertet

### Requirement: Der stabile 1.0.0-Candidate nutzt die kanonische Releasepipeline

Die drei kanonischen Candidate-Einstiege MUST die laut SemVer-Plan erwartete stabile Version `1.0.0` konsistent erlauben und MUST ungueltige, alte oder nicht erwartete Versionen fail-closed ablehnen. Es darf keine parallele Generator-, Validator- oder Promotionspipeline entstehen.

#### Scenario: Stabile Zielversion

- **WHEN** der kanonische Generator mit `1.0.0` auf dem freigegebenen Source-Commit aufgerufen wird
- **THEN** entsteht ein Schema-v4-Candidate mit PENDING-Status und ohne finale Source- oder Tagevidence

#### Scenario: Ungueltige Version

- **WHEN** ein Candidate mit syntaktisch ungueltiger oder nicht erwarteter Version erzeugt oder validiert wird
- **THEN** lehnt der kanonische Einstieg den Aufruf fail-closed ab

### Requirement: Schema v4 bindet Git-Dateimodi und den vollstaendigen V1-Payload

Jeder Schema-v4-Payloadrecord MUST Pfad, Git-Dateimodus, Groesse und SHA-256 des gebundenen Git-Blobs enthalten. Checksums, Bundle-Digest, Validator und Promotion MUST dieselben sortierten Werte verwenden. Der V1-Payload MUST den integrierten P0-Skillkatalog enthalten. Fehlende, manipulierte oder nicht unterstuetzte Modi sowie Payload-Selbstbezug MUST fail-closed abgewiesen werden. Finale Schema-v1/v2/v3-Manifeste MUST aus Kompatibilitaetsgruenden weiter pruefbar bleiben.

#### Scenario: Modusmanipulation

- **WHEN** ein Payloadrecord seinen Modus auslaesst oder ein Blob zwischen `100644` und `100755` umgebunden wird
- **THEN** lehnt das Binding-Gate den Candidate mit einem stabilen Fehlercode ab

#### Scenario: Historisches Finalmanifest

- **WHEN** ein unveraendertes veroeffentlichtes Schema-v1/v2/v3-Finalmanifest geprueft wird
- **THEN** bleibt seine legacy Checksum-Semantik gueltig, ohne alte Candidates wieder zuzulassen
