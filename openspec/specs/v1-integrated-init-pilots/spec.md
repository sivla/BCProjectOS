# v1-integrated-init-pilots Specification

## Purpose
TBD - created by archiving change spectra-v1-integrated-init-pilots. Update Purpose after archive.
## Requirements
### Requirement: Beide V1-Profile sind aus einem gebundenen Release bedienbar
Spectra MUST je einen isolierten `implementation`- und `support-only`-Workspace über Guided Init aus einem final gebundenen Release erzeugen und read-only validieren.

#### Scenario: Implementation-Profil
- **WHEN** ein Operator das Implementation-Profil mit dem empfohlenen vollständigen Blueprintsatz initialisiert
- **THEN** sind Projektbereich, Jira-Struktur, Blankovorlagen und Metadaten vorhanden und validiert

#### Scenario: Support-only-Profil
- **WHEN** ein Operator das Supportprofil initialisiert
- **THEN** entsteht ein schlanker Supportworkspace ohne vorsorglich erzeugte Consulting-Blankovorlagen

### Requirement: Der integrierte Bedienpfad umfasst Recovery
Spectra MUST beide erzeugten Workspaces deterministisch sichern, in ein leeres Ziel wiederherstellen und danach erneut vollständig validieren.

#### Scenario: Backup-/Restore-Roundtrip
- **WHEN** ein gültiger Pilotworkspace gesichert und wiederhergestellt wird
- **THEN** bleiben Releasebindung, Projektvertrag, Blueprintauswahl und fachliche Evidence valide

### Requirement: V1-Pilotevidence ist maschinenlesbar und fail-closed
Spectra MUST die integrierte Pilotstrecke mit Releasebindung, Profilresultaten, Dokumentationsstatus, offenen P1/P2 und GO/NO-GO-Entscheidung belegen.

#### Scenario: Manipulierte Evidence
- **WHEN** Bindung, Profilresultat, Blueprintgrenze, Recovery, Dokumentation oder Prioritätsstatus manipuliert ist
- **THEN** lehnt der Evidencevalidator mit einem stabilen Fehlercode ab
