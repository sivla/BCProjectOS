# Proposal: Spectra in bestehende Projekte einfuehren

## Warum

Bestehende Kunden- und Supportprojekte besitzen bereits eigene Jira- und Confluence-Strukturen. Ein Spectra-Rollout darf diese Strukturen weder durch einen Standard ersetzen noch BC-Basic-spezifische Annahmen hineintragen. Vor jeder Uebernahme braucht es eine reproduzierbare Bestandsaufnahme, ein projektspezifisches Mapping und einen explizit pruefbaren Plan.

## Ziel

Spectra erhaelt einen portablen Existing-Project-Adoption-Vertrag. Er nimmt exportierte Jira-/Confluence-Discovery-Daten read-only auf, bindet sie an Site, Projekt, Board, Spaces und Revisionen, erzeugt ein explizites Mapping sowie einen Adoption-Plan und kann daraus atomar einen lokalen Spectra-Workspace anlegen. Live-Remote-Schreiben bleibt ohne spaeteren autorisierten Adapter gesperrt.

## Scope

- PowerShell-Oberflaeche mit `inspect`, `configure`, `plan`, `adopt`, `validate` und kontrolliertem `apply`;
- portable Konfiguration fuer Implementation und Support-only;
- revisiongebundene Jira-/Confluence-Discovery mit projektspezifischem Mapping;
- Planpositionen `adopt-as-is`, `explicit-map` und `improvement-proposal`;
- lokaler Workspace mit Produktbindung, Inbox-/Proposal-Grenze und Bestandsinventar;
- Offline-Fixtures fuer zwei deutlich verschiedene bestehende Projektstrukturen;
- fail-closed Validatoren, Negativmatrix, Upgrade- und Backup/Restore-Nachweis;
- deutsches Anwenderhandbuch und Adaptervertrag fuer einen spaeteren Live-Connector.

## Nicht-Scope

- kein Live-Aufruf von Jira, Confluence oder Atlassian APIs;
- keine Tokens, Passwoerter, Browserprofile, Kundendaten oder reale Evidence;
- kein automatisches Anlegen, Umbenennen, Umsortieren oder Loeschen;
- kein BC-Basic-Hardcoding und keine feste Ticketanzahl;
- keine neue Spectra-Version, kein finales Manifest, Tag, Push oder Release.

## Releasegrenze

Der bestehende lokale `1.0.0`-Candidate bleibt unveraendert. Dieser Change erzeugt zunaechst einen commitgebundenen Adoption-Artefaktnachweis, aber keinen neuen Spectra-Releasecandidate. Ein kanonischer Releasecandidate benoetigt nach dem Produktcommit einen eigenen Evidencecommit und eine separat aus der Releasepolicy abgeleitete Version.
