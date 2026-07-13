# Project Init Ticket Mapping

## MODIFIED Requirements

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
