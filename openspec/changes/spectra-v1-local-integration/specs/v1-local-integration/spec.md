# v1-local-integration Specification

## Purpose

Dieser Vertrag beschreibt ausschließlich die lokale Konsolidierung zweier belegter Spectra-V1-Vertragslinien. Er fuehrt keine neue Produktfunktion und keine Releaseversion ein.

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

### Requirement: Integration ist kein Release

Der Integrationsstand MUST `PENDING_BCPROJECTOS_RELEASE` bleiben und MUST weder Candidate-, Manifest-, Tag- noch Published-Evidence fuer eine neue Version erzeugen.

#### Scenario: Unzulaessiger Releaseclaim

- **WHEN** der Integrationsdelta eine neue Version oder Releasebindung behauptet
- **THEN** wird die Uebergabe als NO-GO bewertet
