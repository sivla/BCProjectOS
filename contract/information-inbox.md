# Kontrollierte Informations-Inbox

Die Informations-Inbox nimmt Quellen unveränderlich auf und erzeugt ausschließlich nachvollziehbare Vorschläge. Sie schreibt keine Jira-, Confluence-, Budget-, Status- oder Dokumentquelle. Annahme und Umsetzung bleiben getrennte menschlich auditierbare Schritte.

Der Vertrag unterstützt Kunden mit beliebig vielen Projekten sowie Supportfälle ohne Projekt. Jede Quelle ist revision- und SHA-256-gebunden. Fehlende Provenienz, unsichere Pfade, Secrets, unbekannte Ziele, Selbstfreigaben, doppelte Verarbeitung und rückwirkende Quelländerungen werden fail-closed abgelehnt.

Die aktuelle Implementierung ist lokal, synthetisch und read-only. Connectoren, UI und eine spätere Ausführung angenommener Vorschläge sind nicht Bestandteil dieses Blocks.
