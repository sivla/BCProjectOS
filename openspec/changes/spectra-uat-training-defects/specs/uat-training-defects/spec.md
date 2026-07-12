## ADDED Requirements

### Requirement: UAT, Schulung und Defects führen zu einer belastbaren Exit-Entscheidung
Spectra MUST generische BC-Basic-Prozessabdeckung, fachliche Tests, Rollenbefähigung, Defect-Triage und Evidence referenziell verbinden. Ein Exit-GO MUST bei offenen P1/P2 fail-closed blockiert werden.

#### Scenario: Vollständige synthetische UAT
- **WHEN** ein Implementation- oder Support-only-Profil erzeugt wird
- **THEN** sind Entry, Prozessabdeckung, vier Pfadarten, Rollen, Evidence und Exit deterministisch validierbar

#### Scenario: Defect und Retest
- **WHEN** ein Defect geschlossen oder erlassen wird
- **THEN** sind Reproduktion, Owner, Statusfolge und Fix-/Retest- oder Waiver-Evidence vollständig referenziert

#### Scenario: Offener hoher Defect
- **WHEN** beim Exit ein P1 oder P2 offen ist
- **THEN** wird ein GO mit stabilem Fehlercode abgelehnt

#### Scenario: Simulationsgrenze
- **WHEN** UAT oder Training synthetisch ausgeführt wird
- **THEN** wird keine Produktions-, Performance-, Kunden- oder Berechtigungsevidence behauptet
