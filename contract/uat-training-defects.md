# UAT, Training und Defects

Dieser Vertrag führt eine BC-Basic-Einführung von der Testvorbereitung bis zur UAT-Exit-Entscheidung. Er enthält keine Kundenwerte und führt keine produktiven BC-Aktionen aus.

## Kernprozesse und UAT

Die Mindestabdeckung umfasst Finance, Purchase-to-Pay, Order-to-Cash, Cash/Bank, Inventory, Month-End und VAT Preview. Jeder fachliche Test besitzt Rolle, Owner, Entry-/Exit-Bezug, Evidence, Entscheidung und einen der Pfade `positive`, `negative`, `exception` oder `retest`.

## Schulung

Jede Rolle besitzt Lernziele, Übungen, Fehlersituationen, Kompetenznachweis, Operator-Smoke und Eskalationsweg. Ein BC-Profil steuert Oberfläche und Arbeitskontext, ist aber kein Berechtigungsnachweis. Reale Rechte werden separat aus Lizenz und zugewiesenen Permissions geprüft.

## Defects und Exit

Defects verwenden P1–P4, reproduzierbare Schritte, Triage, Owner und kontrollierte Statusfolgen. `resolved` oder `closed` benötigt Fix- und Retest-Evidence. `waived` benötigt eine explizite Entscheidung. Exit-GO ist nur bei null offenen P1/P2 zulässig.

## Simulationsgrenze

Sandbox und synthetische Fixtures sind für Training und funktionale Prüfung geeignet, aber kein Produktions-, Integrations- oder Performancebeweis. Technische Testautomation ersetzt keine fachliche UAT-Entscheidung.

## Offizielle Microsoft-Referenzen

- https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/environment-types
- https://learn.microsoft.com/en-us/dynamics365/business-central/admin-users-profiles-roles
- https://learn.microsoft.com/en-us/dynamics365/business-central/ui-define-granular-permissions
- https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testing-application
- https://learn.microsoft.com/en-us/training/paths/process-sales-purchasing-business-central/
- https://learn.microsoft.com/en-us/training/paths/process-financial-operations-business-central/

P1–P4, Waiver, Retest-Evidence und das Exit-Gate sind Spectra-Governance, keine Microsoft-Vorgabe.
