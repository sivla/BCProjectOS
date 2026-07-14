# Production Customer Onboarding Readiness

## ADDED Requirements

### Requirement: Readinesszustände bleiben getrennt

Spectra MUST Plattformbereitschaft, Onboardingbereitschaft und reale Kunden-Go-live-Bereitschaft getrennt bewerten. Für das Produkt MUST `customerGoLiveReady` exakt `not-applicable` mit `evidenceMode=none` sein.

#### Scenario: Voreiliges Go-live-Grün
- **WHEN** Produkt-Evidence einen konkreten Kunden-Go-live-Status als bestanden behauptet
- **THEN** lehnt die Validierung mit `READINESS_CUSTOMER_GOLIVE_FORBIDDEN` ab

### Requirement: Vier Onboardingprofile sind deterministisch

Spectra MUST `implementation`, `support-only`, `fit-gap` und `migration` als getrennte Projektarten planen. Eine optionale Vorgängerreferenz MUST stabil und kundenintern sein.

#### Scenario: Unbekanntes Profil
- **WHEN** die Eingabe eine andere Projektart enthält
- **THEN** lehnt die Validierung mit `READINESS_PROFILE_UNKNOWN` ab

### Requirement: Onboarding bleibt fail-closed und kundenisoliert

Persistierte Pfade MUST relativ sein. IDs MUST eindeutig sein. Cross-Customer-Referenzen, Secrets, fehlende Release-Evidence und `live`-Atlassian-Apply MUST abgelehnt werden.

#### Scenario: Gefährliche Eingabe
- **WHEN** ein Secretwert, absoluter Pfad, doppelte ID, fremde Kundenreferenz oder Live-Apply vorkommt
- **THEN** wird mit einem stabilen Readiness-Code abgelehnt

### Requirement: Der Operatorplan deckt den Lebenszyklus ab

Der Plan MUST Releasepreflight, Init oder Adoption, Register, Validate, Upgradeplanung, Backup/Restore, Snapshot-Handoff, Support und Uninstall enthalten und bei gleicher Eingabe byteidentisch sein.

#### Scenario: Wiederholte Planung
- **WHEN** dieselbe validierte Eingabe erneut geplant wird
- **THEN** bleibt der Plan byteidentisch und die vorhandene Zieldatei wird nicht neu geschrieben

### Requirement: Distribution bleibt ohne Lizenzentscheidung begrenzt

Ohne explizite Benutzerentscheidung MUST Distribution höchstens `internal-only` und `licenseDecision=pending` sein.

#### Scenario: Public ohne Lizenzentscheidung
- **WHEN** `licenseDecision=pending` mit `status=public` kombiniert wird
- **THEN** lehnt die Validierung mit `READINESS_DISTRIBUTION_LICENSE_REQUIRED` ab
