# Project Init and Onboarding

## ADDED Requirements

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
Spectra MUST Confluence-Seitenbaum und Jira-Arbeitsstruktur als dateibasierten Vertrag erzeugen; Live-Zugriff oder gespeicherte Zugangsdaten sind nicht erforderlich und nicht erlaubt.

#### Scenario: Portabler Kollaborationsvertrag
- **WHEN** `portable-atlassian` gewählt wird
- **THEN** erzeugt Spectra lokale Seiten- und Vorgangsstrukturen mit deaktiviertem Live-Schreibzugriff
