# Proposal: Spectra-V1-Vertragslinien lokal konsolidieren

## Warum

Seit dem veroeffentlichten `spectra-v1.0.0-rc.1` wurden zwei lokale, jeweils belegte Vertragslinien aufgebaut. Die breitere RC2/RC3/P0-Linie und die neuere Produktvertragslinie teilen RC.1 als Merge-Base, sind aber nicht integriert. Ohne kontrollierte Konsolidierung bestehen parallele Wahrheiten fuer Inbox, Blueprints und Business-Central-Wissen.

## Ziel

Dieser Change fuehrt beide Linien lokal und ohne Funktionsausweitung zusammen. Er bestimmt je Konfliktklasse genau einen fuehrenden Vertrag, erhaelt kompatible Herkunftspfade und belegt die integrierte Ausfuehrbarkeit. Nach der unabhaengig bestandenen Integrationsabnahme schliesst derselbe WIP-1-Change ausschließlich die zwingende Releasevertragsluecke und erzeugt daraus einen lokalen, nicht installierbaren `1.0.0`-Candidate fuer einen spaeteren getrennten Review- und Promotionsprozess.

## Scope

- Merge der P0-Linie `2c02c5970b7592fac3fd1fc810b202319c7318ba` mit dem archivierten Knowledge-Playthrough-Stand `6c22c4a9cff7808bb63c14880fdaba9973733fab`.
- Kontrollierte Schichtung von Customer-Workspace-Inbox und Information-Inbox-Proposals.
- Blueprint-Katalog V2 als fuehrender Vorschauvertrag bei lesbarer Legacy-Herkunft.
- Genau eine byteidentische BC Reference Library mit Consultant-Knowledge als fachlicher Schicht darueber.
- Erhalt des P0-Skillkatalogs und der variablen Project-Story-Kardinalitaet.
- Integrationsmatrix, Gap-Matrix und commitgebundene Tests.
- Kanonische Stable-SemVer-Unterstuetzung fuer exakt den geplanten `1.0.0`-Candidate, ohne alte oder ungueltige Versionen zu akzeptieren.
- Schema-v4-Bindung von Git-Dateimodus, Groesse und SHA-256 jedes Payloadblobs sowie Aufnahme des P0-Skillkatalogs in den Produktpayload.
- Zwei getrennte lokale Commits: zuerst der Releasevertragsfix, danach ausschließlich die daran gebundene Candidate-Evidence.

## Nicht-Scope

- keine neue Fachfunktion, kein neuer Connector und kein Livezugriff;
- keine Kunden-, Tenant-, Personen-, Authentifizierungs- oder Runtime-Evidence-Daten;
- kein finales Manifest, kein Tag, kein Push, keine GitHub-Veroeffentlichung und keine Published-Behauptung;
- keine nachgelagerten V1.x-Folgefaehigkeiten im Candidatezyklus;
- keine Umschreibung, Rebase- oder Force-Aenderung der beiden Quelllinien.

## Wahrheitsgrenze

Veroeffentlicht bleibt ausschließlich `spectra-v1.0.0-rc.1`. Der lokale `1.0.0`-Candidate bleibt `PENDING_BCPROJECTOS_RELEASE`, `CONTRACT_REFERENCE_ONLY` und nicht installierbar; finale Source-, Tag-, Published- und Installierbarkeitsevidence entsteht erst in einem spaeteren, separat freigegebenen Promotionsprozess.
