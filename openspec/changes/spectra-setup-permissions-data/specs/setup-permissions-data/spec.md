## ADDED Requirements

### Requirement: Setup, Berechtigungen und Daten sind als ein Consultant-Durchstich pruefbar
Spectra MUST Setupabhaengigkeiten, Parameterklassifikation, Rollen-/SoD-Proben und drei kontrollierte Datenwellen in einem kundenunabhaengigen Vertrag verbinden.

#### Scenario: Vollstaendiges Implementation-Profil
- **WHEN** das synthetische Implementation-Profil erzeugt wird
- **THEN** sind Setupreihenfolge, Rollenproben, acht Datenvorlagen und drei Wellen vollstaendig validierbar

#### Scenario: Support-only-Profil
- **WHEN** das Support-only-Profil erzeugt wird
- **THEN** bleibt derselbe Vertrag fuer Analyse, Aenderungsplanung und Retest verwendbar, ohne Implementation zu behaupten

#### Scenario: Unsichere oder inkonsistente Eingabe
- **WHEN** Abhaengigkeit, Klassifikation, SoD, Probe, Reihenfolge, Datenreferenz, Kontrollsumme oder Integritaet ungueltig ist
- **THEN** blockiert der read-only Validator mit einem stabilen Fehlercode

#### Scenario: Steuer- oder Lokalisierungswert
- **WHEN** ein Parameter als `localization_or_tax_confirmation` klassifiziert ist
- **THEN** bleibt eine explizite fachliche Bestaetigung erforderlich
