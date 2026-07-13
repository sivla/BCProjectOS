# Specification: Project-Story-Kardinalität

## ADDED Requirements

### Requirement: Variable Sammlungen

Der Project-Story-Validator MUST jede zulässige Sammlung anhand ihrer tatsächlichen Elemente prüfen. Er MUST keine feste Anzahl von Pages, Tickets, Timeline-Ereignissen oder Hypercaretagen als Produktvertrag erzwingen.

#### Scenario: Kleine gültige Story

- WHEN ein gültiger Vertrag zwei Tickets und die dazugehörigen Referenzen enthält
- THEN wird er ohne künstliche Auffüllung akzeptiert.

#### Scenario: Größere gültige Story

- WHEN ein gültiger Vertrag mehr als zwanzig Tickets mit vollständigen Referenzen enthält
- THEN wird er nach denselben Regeln akzeptiert.

#### Scenario: Feste Count-Annahme

- WHEN ein Validator eine synthetische Fixture-Anzahl als notwendige Produktmenge verwendet
- THEN wird dies als `STORY_CARDINALITY_FIXED_COUNT` abgelehnt.

### Requirement: Hierarchie und Referenzen

Der Validator MUST alle IDs domänenbezogen eindeutig prüfen und Parent-, Epic- und Abhängigkeitsreferenzen nach vollständigem Map-Aufbau validieren.

#### Scenario: Unbekannter Parent

- WHEN ein Element auf eine nicht vorhandene Parent-ID zeigt
- THEN wird `STORY_PARENT_ORPHAN` ausgegeben.

#### Scenario: Parent-Zyklus

- WHEN eine Parent-Kette zu einer bereits besuchten ID zurückkehrt
- THEN wird `STORY_PARENT_CYCLE` ausgegeben.

#### Scenario: Doppelte ID oder gebrochene Referenz

- WHEN eine ID doppelt vorkommt oder eine Referenz außerhalb ihrer zulässigen Domäne zeigt
- THEN wird fail-closed `STORY_DUPLICATE_ID` beziehungsweise `STORY_REFERENCE_INVALID` ausgegeben.

### Requirement: Profilabhängige Leere

Ein Profil MUST explizit deklarieren, welche Sammlungen leer sein dürfen. Der Validator MUST eine leere Sammlung weder pauschal als Fehler noch pauschal als vollständigen Projektstand behandeln.

#### Scenario: Support-only ohne Projektstory

- WHEN ein Support-only-Profil keine Implementierungsphase besitzt und dies im Vertrag deklariert ist
- THEN bleibt die entsprechende Sammlung leer und der Workspace gültig.
