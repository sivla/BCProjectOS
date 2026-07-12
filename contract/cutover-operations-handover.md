# Cutover-, Betriebs- und Handover-Vertrag

Der Vertrag führt einen BC-Basic-Workspace nach bestandenem UAT-Exit durch Mock-Cutover, Go/No-Go, Go-live-Simulation, Hypercare, Restart und Supportübergabe. Er ist eine wiederverwendbare Arbeitsgrundlage für PM, Consultant, Process Owner und Support.

Pflichtkette: `UAT-Exit -> Cutover-Sequenz -> Mock-Ist-Abgleich -> Go/No-Go -> Hypercare -> Restart/Recovery -> Supportannahme -> Handover`.

GO ist nur mit vollständigen Kriterien und Evidence sowie ohne offene P1/P2 zulässig. Restart benötigt einen letzten gültigen Zustand und eine Backup-/Restore-Referenz. Handover benötigt Supportannahme, Known Issues und Abschlussnachweis.

Alle Repository-Fixtures sind `synthetic_non_production`. Sie sind keine Kunden-, Produktions-, Berechtigungs- oder fachliche Freigabeevidence.
