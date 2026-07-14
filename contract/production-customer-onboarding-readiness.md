# Produktionsreife Kunden-Onboarding-Bereitschaft

Spectra trennt drei Wahrheiten: Die Produktplattform kann releasegebunden installierbar sein, der Onboardingweg kann für einen neuen isolierten Kundenworkspace vollständig sein, und trotzdem ist kein konkretes Kundenprojekt automatisch go-live-bereit.

Der portable Operatorvertrag unter `schemas/production-customer-onboarding-readiness.schema.json` bindet stabile Kunden-, Workspace- und Projekt-IDs, genau eines der Profile `implementation`, `support-only`, `fit-gap` oder `migration`, einen veröffentlichten Spectra-Release, BC-Betriebsart und Lokalisierung, Umgebungsrollen, einen nicht-live Atlassian-Modus sowie Daten-, Secret- und Recoverygrenzen.

Die Eingabe enthält keine Kundeninhalte. Geheimnisse werden nur als Namen von Runtime-Secretreferenzen angegeben. Persistierte absolute Pfade, Live-Apply und Cross-Customer-Vorgänger sind verboten. External-File-Intake erzeugt höchstens Vorschläge.

Der Operatorplan ist read-only und nennt: Releasepreflight, Init oder Brownfield-Adoption, Register, Validate, Upgradeplanung, Backup/Restore, Snapshot-Handoff, Support und Uninstall. Eine spätere Ausführung nutzt die bereits vorhandenen expliziten Apply-/Approve-Gates.

Reale Tenant-, Lizenz-, Zugangs-, Rollen-/Berechtigungs-, UAT-, Cutover-, Abschluss- und Steuerfreigaben gehören ausschließlich in die Kundeninstanz. Deshalb ist `customerGoLiveReady` im Produktnachweis immer `not-applicable`.
