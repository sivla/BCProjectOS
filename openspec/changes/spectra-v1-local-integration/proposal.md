# Proposal: Spectra-V1-Vertragslinien lokal konsolidieren

## Warum

Seit dem veroeffentlichten `spectra-v1.0.0-rc.1` wurden zwei lokale, jeweils belegte Vertragslinien aufgebaut. Die breitere RC2/RC3/P0-Linie und die neuere Produktvertragslinie teilen RC.1 als Merge-Base, sind aber nicht integriert. Ohne kontrollierte Konsolidierung bestehen parallele Wahrheiten fuer Inbox, Blueprints und Business-Central-Wissen.

## Ziel

Dieser Change fuehrt beide Linien lokal und ohne Funktionsausweitung zusammen. Er bestimmt je Konfliktklasse genau einen fuehrenden Vertrag, erhaelt kompatible Herkunftspfade und belegt die integrierte Ausfuehrbarkeit. Das Ergebnis ist ausschließlich ein lokaler Integrationsstand fuer einen spaeteren getrennten Releaseprozess.

## Scope

- Merge der P0-Linie `2c02c5970b7592fac3fd1fc810b202319c7318ba` mit dem archivierten Knowledge-Playthrough-Stand `6c22c4a9cff7808bb63c14880fdaba9973733fab`.
- Kontrollierte Schichtung von Customer-Workspace-Inbox und Information-Inbox-Proposals.
- Blueprint-Katalog V2 als fuehrender Vorschauvertrag bei lesbarer Legacy-Herkunft.
- Genau eine byteidentische BC Reference Library mit Consultant-Knowledge als fachlicher Schicht darueber.
- Erhalt des P0-Skillkatalogs und der variablen Project-Story-Kardinalitaet.
- Integrationsmatrix, Gap-Matrix und commitgebundene Tests.

## Nicht-Scope

- keine neue Fachfunktion, kein neuer Connector und kein Livezugriff;
- keine Kunden-, Tenant-, Personen-, Authentifizierungs- oder Runtime-Evidence-Daten;
- kein Candidate, keine neue Version, kein Manifest, kein Tag und keine Releasebehauptung;
- keine Umschreibung, Rebase- oder Force-Aenderung der beiden Quelllinien.

## Wahrheitsgrenze

Veroeffentlicht bleibt ausschließlich `spectra-v1.0.0-rc.1`. Der Integrationsbranch bleibt `PENDING_BCPROJECTOS_RELEASE`, bis ein spaeterer separater Candidate-, Review-, Promotion- und Postcheck-Prozess erfolgreich abgeschlossen wurde.
