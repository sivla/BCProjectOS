# BC-Wissensbasis und Playthrough-Vertraege

## ADDED Requirements

### Requirement: Aussagen besitzen eindeutige Wahrheitsklasse und Provenienz
Jede Aussage MUST genau eine Klasse `official_documented`, `derived_standard_metadata`, `tested_generic_procedure` oder `open_assumption` sowie Version, Locale und belastbare Provenienz besitzen.

#### Scenario: Ungebundene Aussage
- **WHEN** URL/Repo, Titel, Herausgeber, Stand, Version, Locale oder Digest/Commit fehlt
- **THEN** wird die Aussage fail-closed abgelehnt.

### Requirement: Startkatalog bleibt lean und filterbar
Der Katalog MUST die vereinbarten BC-Basic-Funktionsbereiche abdecken und nach Prozess, Rolle, Seite/Tabelle, Projektphase und Aufgabenart deterministisch filterbar sein.

#### Scenario: Finance-Query
- **WHEN** nach Finance, Consultant und Setup gefiltert wird
- **THEN** werden nur passende, quellengebundene Eintraege in stabiler Reihenfolge geliefert.

### Requirement: Playthrough ist Plan und keine Live-Ausfuehrung
Company- und Konfigurationspaketverfahren MUST Preconditions, Plan, Readback, Fehlerbehandlung und Stop-Codes liefern, ohne BC oder Kundenquellen zu veraendern.

#### Scenario: Wiederholte Vorschau
- **WHEN** derselbe Plan zweimal erzeugt wird
- **THEN** sind Ergebnis und Digest identisch und es gibt keine externen Writes.

### Requirement: CRONUS bleibt Demo-Baseline
Ein CRONUS-Ausgang MUST als Microsoft-Demo-Baseline markiert sein. Umbenennen oder Kopieren MUST NOT als konfigurierte Kundeninstanz gelten.

#### Scenario: CRONUS als fertiger Pilot
- **WHEN** ein Plan die kopierte oder umbenannte Demo als kundenfertig bezeichnet
- **THEN** wird `BC_KNOWLEDGE_CRONUS_NOT_CUSTOMER_READY` ausgegeben.

### Requirement: Quellen sind gepinnt und extern gecacht
Vendor-Repositories MUST ausserhalb von Produkt- und Kundenrepos liegen und Query-Provenienz MUST exakte Commits, Trees und Digests verwenden.

#### Scenario: Floating Quelle
- **WHEN** nur ein Branchname oder ein lokaler absoluter Vendorpfad vorliegt
- **THEN** ist die Wissensquelle nicht queryfaehig.
