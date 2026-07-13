# Generische Dokument- und Jira-Projektion

## Purpose

Dieser Vertrag projiziert quellgebundene Dokumentations- und Jira-Strukturen deterministisch, ohne authored Inhalte oder Kundenwahrheit zu ueberschreiben.

## Requirements

### Requirement: Dokumentation ist beliebig hierarchisch
Spectra MUST 1..N Spaces, beliebig viele Rootknoten und explizite Home-Referenzen ohne feste Kunden- oder Projekttopologie validieren.

#### Scenario: Mehrere Spaces
- **WHEN** ein gueltiger Workspace mehrere source-defined Spaces und Rootknoten besitzt
- **THEN** werden Hierarchie und Home-Referenzen ohne feste Kardinalitaet validiert

### Requirement: Generierte und authored Inhalte bleiben getrennt
Spectra MUST generierte Dokumente vollständig an Blueprint, Quellrevisionen, Snapshot, Digest und Erzeugungszeit binden und authored Dokumente vor Überschreibung schützen.

#### Scenario: Authored Dokument
- **WHEN** eine Projektion ein authored Dokument als Ziel adressiert
- **THEN** wird jede automatische Ueberschreibung abgelehnt

### Requirement: Referenzen und Provenienz sind fail-closed
Spectra MUST Zyklen, doppelte IDs oder Orders, unbekannte Parents/Dokumente, Cross-Customer-Referenzen, unsichere Origins und fehlende Provenienz ablehnen.

#### Scenario: Gebrochene Hierarchie
- **WHEN** ein Knoten einen Zyklus, unbekannten Parent oder Cross-Customer-Bezug erzeugt
- **THEN** wird die Projektion fail-closed abgelehnt

### Requirement: Renderer bleibt lokal und deterministisch
Spectra MUST gleiche validierte Eingaben byteidentisch rendern und darf authored Dateien nicht überschreiben.

#### Scenario: Wiederholtes Rendern
- **WHEN** dieselbe validierte Eingabe zweimal gerendert wird
- **THEN** sind alle generated Artefakte byteidentisch
