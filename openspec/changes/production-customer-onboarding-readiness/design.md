# Design: Produktionsreife Kunden-Onboarding-Bereitschaft

## Zustände

`platformReady` belegt die installierbare und prüfbare Produktplattform. `onboardingReady` belegt einen vollständigen, isolierten Startpfad. `customerGoLiveReady` ist für das Produkt Spectra stets `not-applicable`: reale Tenant-, Lizenz-, Zugangs-, Rollen-, UAT-, Cutover-, Abschluss- und Steuerfreigaben gehören in die Kundeninstanz.

## Operatorweg

Eine portable JSON-Eingabe wird zuerst ohne Writes vorgeprüft, anschließend deterministisch in einen Plan projiziert und separat validiert. Persistierte Pfade sind relativ; Secretwerte und Live-Apply sind verboten. Der Plan nennt Init oder Brownfield-Adoption, Register, Validate, Upgradeplanung, Backup/Restore, Snapshot-Handoff, Support und sicheren Uninstall als explizite Schritte.

## Distribution

Ohne Benutzerentscheidung zur Lizenz bleibt Distribution `internal-only` mit `licenseDecision=pending`. Das ist kein Installierbarkeits- oder Veröffentlichungsclaim.
