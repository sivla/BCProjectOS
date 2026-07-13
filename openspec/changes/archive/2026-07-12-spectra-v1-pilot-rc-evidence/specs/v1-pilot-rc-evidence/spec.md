## ADDED Requirements

### Requirement: RC-Reife benötigt zwei unabhängige, reproduzierbare Piloten
Spectra MUST vor einer RC-Behauptung einen Implementation- und einen Support-only-Pilot aus frischem Clone vollständig, isoliert und synthetisch nachweisen.

#### Scenario: Implementation-Pilot
- **WHEN** ein unabhängiger Anwender den veröffentlichten Release nutzt
- **THEN** ist der generische Projektweg von Engagement bis Handover ohne verborgenes Wissen reproduzierbar

#### Scenario: Support-only-Pilot
- **WHEN** ein unabhängiger Anwender das Support-only-Profil nutzt
- **THEN** sind Supportannahme, Ticket-/Evidence-Pfade, Recovery und Übergabe ohne künstliche Implementierungsphasen reproduzierbar

#### Scenario: RC-Gate
- **WHEN** ein RC vorgeschlagen wird
- **THEN** sind beide Piloten, Upgrade, Backup/Restore, Manipulationsmatrix, Dokumentation und null offene P1/P2 belegt

#### Scenario: Wahrheitsgrenze
- **WHEN** synthetische Piloten bestehen
- **THEN** wird weder Kunden- noch Produktiv- oder Live-BC-Evidence behauptet
