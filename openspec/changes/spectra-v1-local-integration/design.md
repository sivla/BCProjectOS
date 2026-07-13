# Design: Lokale V1-Integrationskonsolidierung

## Ausgangsgraph

- Merge-Base und veroeffentlichte Basis: `0c4542f8e69c3a7d52807b96b9bdd50a54309371`.
- Integrationsbasis: `2c02c5970b7592fac3fd1fc810b202319c7318ba`.
- Zweite Linie: `b7ec32e5a31e0cb1a3ef1c2bebba193ef9901e5c`, abgeschlossen durch reinen OpenSpec-Archivcommit `6c22c4a9cff7808bb63c14880fdaba9973733fab`.
- Foundation-Ursprung der BC Reference Library: `dff88684d062e23794cbfb5423aecd331ac49790`.

## Integrationsprinzipien

1. Ein normaler Merge erhaelt beide Historien und ihre Provenienz.
2. Neuere spezialisierte Vertraege liegen auf vorhandenen Foundations, statt sie zu duplizieren.
3. Legacy-Pfade bleiben nur dort lesbar, wo Bestandskompatibilitaet erforderlich ist; sie werden nicht als zweite fuehrende Wahrheit weiterentwickelt.
4. Tests beweisen jede Konfliktentscheidung durch einen positiven Pfad und eine gezielte Manipulation.
5. Release-Evidence bleibt historisch. Der Merge erzeugt weder Candidate- noch Final-Evidence.

## Konfliktentscheidungen

### Inbox

Das Customer-Workspace-Modell bleibt fuer Customer, Environment, Company, Project, Support Case, Rollen und Basis-Inbox zustaendig. Der Information-Inbox-Vertrag ist die fuehrende Verarbeitungsschicht fuer unveraenderlichen Intake, Proposalstatus, Review, getrennte Annahme und Umsetzung. Keine Schicht darf Zielartefakte direkt mutieren.

### Blueprints

Der maschinenlesbare Blueprint-Katalog V2 ist fuer neue Vorschauen fuehrend. Der kuratierte Katalog der P0-Linie bleibt als Legacy-Herkunft fuer bestehende Init-Auswahlen lesbar. Seine Blankoartefakte duerfen ausschliesslich als explizit vom V2-Blueprint referenzierte Kompatibilitaetsprojektion materialisiert werden; sie sind keine zweite Template-Wahrheit. Vorschau, Space-Auswahl und fuehrende Ablageorte stammen immer aus V2.

### Business-Central-Wissen

Die 14 Foundation-Dateien der BC Reference Library muessen zu `dff88684...` blobgleich bleiben. Consultant-Knowledge und Playthrough-Vertraege nutzen deren gepinnte Source-Locks, Objektkatalog und Query-Grenzen. Ungepinnte Quellen und `CRONUS = kundfertig` bleiben fail-closed.

### Skills und Kardinalitaet

P0-Skills konsumieren die integrierten Vertraege und duerfen weder direkte Kundenmutation noch ungepinnte Wissensquellen erlauben. Project-Story-Mengen werden aus der validierten Instanz abgeleitet; feste Seiten-, Ticket-, Timeline- oder Hypercare-Anzahlen sind unzulaessig.

## Commitstrategie

Der normale Mergecommit enthaelt die Quellhistorien, fachliche Konfliktaufloesung, Change-Grundlage und Gap-Matrix. Hoechstens ein nachgelagerter Integrationsfix-/Evidencecommit darf aufgrund realer Gatebefunde Tests, Guardrails oder Evidence korrigieren. Neue Features sind ausgeschlossen.
