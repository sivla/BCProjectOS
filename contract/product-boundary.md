# Produktgrenze

Status: Accepted for MVP 0

BCProjectOS ist eine lokale Arbeits-, Wissens- und Governance-Schicht je Business-Central-Kunde. Es verbindet kuratiertes Unternehmens- und Prozesswissen, Projekte, Supportfaelle, Meetings, externe Dateien, Tickets, Requirements, OpenSpec-Changes und Evidence durch stabile IDs und explizite Relationen.

BCProjectOS ist nicht die operative Source of Truth fuer Business-Central-Daten, externe Ticketworkflows, veroeffentlichte Kollaborationsseiten, Zeiterfassung, Buchhaltung oder Rechnungsstellung. MVP 0 erlaubt keine externen Schreibzugriffe und keine Live-BC-Zugriffe.

Die oberste Einheit ist genau ein physisch getrennter Kundenworkspace. Kundenuebergreifende Verzeichnisse, Relationen und gemeinsame Blob-Stores sind im ersten Produktvertrag verboten. Jeder Kundenworkspace besitzt genau einen OpenSpec-Root.

MVP 0 liefert Vertraege, Kataloge, Schemas, synthetische Fixtures und read-only Validierung. Workspace-Generator, Intake-Verarbeitung, Synchronisation, UI und Delivery-Generatoren gehoeren nicht zu MVP 0.
